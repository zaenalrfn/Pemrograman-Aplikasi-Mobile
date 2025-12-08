import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/schedule_model.dart';

class ScheduleService {
  final String baseUrl = 'http://192.168.222.58:8000/api';
  final String token;

  ScheduleService({required this.token});

  Future<List<ScheduleModel>> getUserSchedules(String userId) async {
    final url = Uri.parse('$baseUrl/student-courses?user_id=$userId');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load schedules: ${response.statusCode}');
    }

    final Map<String, dynamic> jsonData = jsonDecode(response.body);
    if (jsonData['success'] != true || jsonData['data'] == null) return [];

    final List data = jsonData['data'];
    return data.map((item) => ScheduleModel.fromJson(item)).toList();
  }
}
