import 'package:flutter/foundation.dart';
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

    _isLoading = false;
    notifyListeners();
  }

  // JUMLAH HADIR per course
  int getHadirCount(String courseId) {
    return _attendances
        .where((a) => a.courseId == courseId && a.status == 'hadir')
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
}
