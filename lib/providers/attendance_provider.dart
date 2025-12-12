import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/attendance_history_model.dart';
import '../models/schedule_model.dart';
import '../services/attendance_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();

  AttendanceProvider();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ScheduleModel> _schedules = [];
  List<ScheduleModel> get schedules => _schedules;

  List<AttendanceModel> _attendances = [];
  List<AttendanceModel> get attendances => _attendances;

  Future<void> loadData(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1) Ambil daftar matkul si user dari /student-courses
      _schedules = await _attendanceService.getStudentCourses(userId);

      // 2) Ambil semua attendance user (status hadir / alpa)
      _attendances = await _attendanceService.getUserAttendance(userId);
    } catch (e) {
      debugPrint("AttendanceProvider.loadData ERROR: $e");
      _schedules = [];
      _attendances = [];
    }

    // 3) Cek Auto Absent untuk matkul yg sudah lewat jamnya
    try {
      if (_schedules.isNotEmpty) {
        await _checkAndSubmitAutoAbsence(userId);
      }
    } catch (e) {
      debugPrint("AutoAbsent Check Error: $e");
    }

    // 4) Sort Schedules by Recent Attendance
    _sortSchedulesByAttendance();

    _isLoading = false;
    notifyListeners();
  }

  // JUMLAH HADIR per course
  int getHadirCount(String courseId) {
    return _attendances
        .where((a) => a.courseId == courseId && a.status == 'hadir')
        .length;
  }

  // Helper untuk Cek Double Attendance (Hari Ini)
  bool hasAttendedToday(String courseId) {
    if (_attendances.isEmpty) return false;

    final nowStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Cek apakah ada record attendance utk courseId ini & tanggal == hari ini
    // Kita anggap status 'hadir' atau 'sakit'/'izin' yg valid count sbg 'attended'.
    // Kalau 'tidak hadir' (auto absent) mungkin tidak kita anggap attended?
    // User request: "ga bisa dobel absen". Biasanya artinya kalau sdh absen HADIR, gabisa absen lagi.
    // Kalau statusnya 'tidak hadir' karena auto-absen, apakah boleh scan lagi?
    // Asumsi: Kalau sdh ada record APAPUN hari ini, kita block.
    // Tapi kalau auto-absen 'tidak hadir' mungkin user ingin memperbaiki?
    // Untuk saat ini kita block jika ada record attendance dengan tanggal hari ini.

    return _attendances.any((a) {
      if (a.courseId != courseId) return false;
      if (a.tanggal == null) return false;
      final aDateStr = DateFormat('yyyy-MM-dd').format(a.tanggal!);
      return aDateStr == nowStr;
    });
  }

  // JUMLAH TIDAK HADIR per course (NEW)
  int getTidakHadirCount(String courseId) {
    return _attendances
        .where(
          (a) =>
              a.courseId == courseId &&
              (a.status?.toLowerCase() == 'tidak hadir' ||
                  a.status?.toLowerCase() == 'absen' ||
                  a.status?.toLowerCase() == 'alpha'), // Added alpha
        )
        .length;
  }

  // PROGRESS = hadir / 14 pertemuan
  double getAttendancePercentage(String courseId) {
    const totalPertemuan = 14;
    final hadir = getHadirCount(courseId);

    return (hadir / totalPertemuan).clamp(0.0, 1.0);
  }

  Future<bool> submitAttendance({
    required String userId,
    required String courseId,
    required String tanggal, // format YYYY-MM-DD
    required String status,
    required String method,
    String? photoCapture,
    bool verified = false,
  }) async {
    _isLoading = true;
    notifyListeners();

    final success = await _attendanceService.performAttendance(
      userId: userId,
      courseId: courseId,
      tanggal: tanggal,
      status: status,
      method: method,
      photoCapture: photoCapture,
      verified: verified,
    );

    if (success) {
      // Refresh data jika berhasil absen
      await loadData(userId);
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> _checkAndSubmitAutoAbsence(String userId) async {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final dayNameMap = {
      1: 'Senin',
      2: 'Selasa',
      3: 'Rabu',
      4: 'Kamis',
      5: 'Jumat',
      6: 'Sabtu',
      7: 'Minggu',
    };
    final currentDayName = dayNameMap[now.weekday];

    bool needsReload = false;

    for (var schedule in _schedules) {
      // 1. Cek apakah matkul ini hari ini
      if (schedule.hari != currentDayName) continue;

      // 2. Cek apakah jam kuliah sudah selesai
      if (schedule.jamSelesai == null) continue;
      if (now.isBefore(schedule.jamSelesai!)) continue; // Belum selesai

      final courseId = schedule.courseId ?? schedule.course?.id;
      if (courseId == null) continue;

      // 3. Cek apakah sudah ada absen hari ini (baik hadir atau tidak hadir)
      // Kita cek di list _attendances yg baru diload
      bool hasRecord = _attendances.any((a) {
        if (a.courseId != courseId) return false;
        if (a.tanggal == null) return false;
        final aDateStr = DateFormat('yyyy-MM-dd').format(a.tanggal!);
        return aDateStr == todayStr;
      });

      if (!hasRecord) {
        debugPrint("Auto Absent triggered for Course $courseId");
        // BELUM ABSEN & SUDAH LEWAT JAM -> POST 'tidak hadir' (status: alpha, method: manual)
        final success = await _attendanceService.performAttendance(
          userId: userId,
          courseId: courseId,
          tanggal: todayStr,
          status: 'alpha', // Changed to 'alpha'
          method: 'face_recognition', // Changed to 'manual'
          photoCapture: '-', // Added hyphen string
          verified: false,
        );
        if (success) needsReload = true;
      }
    }

    if (needsReload) {
      // Refresh data local supaya UI update
      _attendances = await _attendanceService.getUserAttendance(userId);
      notifyListeners();
    }
  }

  void _sortSchedulesByAttendance() {
    // Kita ingin matkul dengan absensi TERBARU (paling akhir tanggals-nya)
    // muncul di paling atas.

    // Helper function untuk dpt tanggal terakhir attendance
    DateTime? getLastAttendanceDate(String courseId) {
      final relevant = _attendances
          .where((a) => a.courseId == courseId)
          .toList();
      if (relevant.isEmpty) return null;

      // Sort attendance by date desc
      relevant.sort((a, b) {
        if (a.tanggal == null && b.tanggal == null) return 0;
        if (a.tanggal == null) return 1;
        if (b.tanggal == null) return -1;
        return b.tanggal!.compareTo(a.tanggal!);
      });

      return relevant.first.tanggal;
    }

    _schedules.sort((a, b) {
      final cIdA = a.courseId ?? a.course?.id;
      final cIdB = b.courseId ?? b.course?.id;

      if (cIdA == null && cIdB == null) return 0;
      if (cIdA == null) return 1;
      if (cIdB == null) return -1;

      final lastDateA = getLastAttendanceDate(cIdA);
      final lastDateB = getLastAttendanceDate(cIdB);

      if (lastDateA == null && lastDateB == null) {
        return 0;
      }
      if (lastDateA == null) return 1; // B has attendance, so B first (A > B)
      if (lastDateB == null)
        return -1; // A has attendance, so A first (A < B in ascending, but we want descending?)

      // Descending order (Latest date top)
      return lastDateB.compareTo(lastDateA);
    });
  }
}
