import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/schedule_model.dart';

class ScheduleService {
  final supabase = Supabase.instance.client;

  Future<List<ScheduleModel>> getUserSchedules(String userId) async {
    final response = await supabase
        .from('schedules')
        .select('''
      *,
      courses:course_id(*,lecturers:dosen_id(*)),
      users:user_id(*)
    ''')
        .eq('user_id', userId);

    if (response == null || response.isEmpty) {
      return [];
    }

    return (response as List)
        .map((item) => ScheduleModel.fromJson(item))
        .toList();
  }
}
