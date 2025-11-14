import 'package:flutter/material.dart';
import '../models/schedule_model.dart';

class SchedulenextcourseProvider extends ChangeNotifier {
  ScheduleModel? _nextCourse;

  // Getter → digunakan halaman Scan
  ScheduleModel? get nextCourse => _nextCourse;

  // Setter → digunakan halaman Beranda
  void setNextCourse(ScheduleModel? course) {
    _nextCourse = course;
    notifyListeners();
  }

  // Opsional untuk clear kalau butuh
  void clearNextCourse() {
    _nextCourse = null;
    notifyListeners();
  }
}
