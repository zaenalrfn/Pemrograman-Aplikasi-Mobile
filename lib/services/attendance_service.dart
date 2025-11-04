import 'package:absensi_mahasiswa/models/attendance_history_model.dart';
import 'package:absensi_mahasiswa/models/course_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceService {
  final supabase = Supabase.instance.client;

  Future<List<CourseModel>> getAllCourses() async {
    final response = await supabase.from('courses').select();
    return (response as List)
        .map((e) => CourseModel.fromJson(e))
        .toList();
  }

  Future<List<AttendanceModel>> getUserAttendance(String userId) async {
    final response = await supabase
        .from('attendance')
        .select()
        .eq('user_id', userId);

    if (response == null || response.isEmpty) return [];

    return (response as List)
        .map((e) => AttendanceModel.fromJson(e))
        .toList();
  }
}
