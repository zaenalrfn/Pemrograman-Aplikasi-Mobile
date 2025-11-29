import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/schedule_model.dart';
import '../services/schedule_service.dart';

class ScheduleProvider extends ChangeNotifier {
  late ScheduleService scheduleService;

  List<ScheduleModel> todaySchedules = [];
  bool isLoading = false;
  DateTime? lastLoadedDate;

  void init(String token) {
    scheduleService = ScheduleService(token: token);
  }

  String normalizeHari(String hari) {
    return hari.toLowerCase().replaceAll("'", "").replaceAll("’", "").replaceAll("`", "").trim();
  }

  Future<void> loadTodaySchedules(String userId, {bool forceReload = false}) async {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE', 'id_ID');
    final today = formatter.format(now);
    final todayNormalized = normalizeHari(today);

    if (!forceReload && todaySchedules.isNotEmpty && lastLoadedDate != null &&
        DateFormat('yyyy-MM-dd').format(lastLoadedDate!) ==
            DateFormat('yyyy-MM-dd').format(now)) return;

    isLoading = true;
    notifyListeners();

    try {
      final allSchedules = await scheduleService.getUserSchedules(userId);

      final filtered = allSchedules.where((s) {
        final dbHari = normalizeHari(s.hari ?? s.course?.hari ?? "");
        return dbHari == todayNormalized;
      }).toList();

      filtered.sort((a, b) {
        final aTime = a.jamMulai ?? DateTime(now.year, now.month, now.day, 0, 0);
        final bTime = b.jamMulai ?? DateTime(now.year, now.month, now.day, 0, 0);
        return aTime.compareTo(bTime);
      });

      todaySchedules = filtered;
      lastLoadedDate = now;
    } catch (e) {
      todaySchedules = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ScheduleModel? get nextSchedule {
  final now = DateTime.now();

  if (todaySchedules.isEmpty) return null;

  // 1) cari yang sedang berjalan
  for (var schedule in todaySchedules) {
    final start = schedule.jamMulai;
    final end = schedule.jamSelesai;
    if (start != null && end != null) {
      if (!now.isBefore(start) && !now.isAfter(end)) {
        // start <= now <= end
        return schedule;
      }
    }
  }

  // 2) cari yang mulai setelah sekarang (upcoming)
  for (var schedule in todaySchedules) {
    final start = schedule.jamMulai;
    if (start != null && start.isAfter(now)) {
      return schedule;
    }
  }

  // 3) kalau semua sudah lewat, kembalikan jadwal terakhir hari ini
  return todaySchedules.last;
}

}
