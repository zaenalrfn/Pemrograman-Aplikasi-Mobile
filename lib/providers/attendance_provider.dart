import 'package:flutter/foundation.dart';
import '../models/attendance_history_model.dart';
import '../models/schedule_model.dart';
import '../services/attendance_service.dart';
import '../services/schedule_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();
  final ScheduleService _scheduleService = ScheduleService();

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
      // Ambil jadwal user
      _schedules = await _scheduleService.getUserSchedules(userId);

      // Ambil attendance user
      _attendances = await _attendanceService.getUserAttendance(userId);
    } catch (e) {
      print("Error loadData: $e");
      _schedules = [];
      _attendances = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  int getHadirCount(String courseId) {
    return _attendances
        .where((a) => a.courseId == courseId && a.status == 'hadir')
        .length;
  }

  double getAttendancePercentage(String courseId) {
    final total = _attendances.where((a) => a.courseId == courseId).length;
    if (total == 0) return 0.0;

    final hadir = _attendances
        .where((a) => a.courseId == courseId && a.status == 'hadir')
        .length;

    return hadir / total;
  }
}
