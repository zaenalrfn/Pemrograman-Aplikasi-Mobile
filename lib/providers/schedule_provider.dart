import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/schedule_model.dart';
import '../services/schedule_service.dart';

class ScheduleProvider extends ChangeNotifier {
  final scheduleService = ScheduleService();
  List<ScheduleModel> todaySchedules = [];
  bool isLoading = false;
  DateTime? lastLoadedDate;

  Future<void> loadTodaySchedules(String userId, {bool forceReload = false}) async {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE', 'id_ID');
    final today = formatter.format(now);

    // ✅ Cegah reload kalau sudah dimuat hari ini
    if (!forceReload &&
        todaySchedules.isNotEmpty &&
        lastLoadedDate != null &&
        DateFormat('yyyy-MM-dd').format(lastLoadedDate!) ==
            DateFormat('yyyy-MM-dd').format(now)) {
      return;
    }

    isLoading = true;
    notifyListeners();

    final allSchedules = await scheduleService.getUserSchedules(userId);

    final filtered = allSchedules.where((s) {
      return s.hari?.toLowerCase() == today.toLowerCase();
    }).toList();

    filtered.sort((a, b) {
      final aTime = a.jamMulai ?? DateTime.now();
      final bTime = b.jamMulai ?? DateTime.now();
      return aTime.compareTo(bTime);
    });

    todaySchedules = filtered;
    lastLoadedDate = now;
    isLoading = false;
    notifyListeners();
  }
}

