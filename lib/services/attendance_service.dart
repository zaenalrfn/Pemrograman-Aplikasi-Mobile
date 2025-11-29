import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/attendance_history_model.dart';
import '../models/schedule_model.dart'; // <- tambah ini

class AttendanceService {
  final String baseUrl = 'http://operasional_absensi_mahasiswa.test/api';
  final String token;

  AttendanceService({required this.token});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // existing methods...
  Future<List<CourseModel>> getAllCourses() async {
    final url = Uri.parse('$baseUrl/courses');

    final response = await http.get(url, headers: _headers);

    if (response.statusCode != 200) {
      debugPrint("getAllCourses ERROR Body: ${response.body}");
      return [];
    }

    final body = jsonDecode(response.body);
    if (body is! List) return [];

    return body
        .map((e) => CourseModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<AttendanceModel>> getUserAttendance(String userId) async {
    final url = Uri.parse('$baseUrl/attendances?user_id=$userId');

    final response = await http.get(url, headers: _headers);

    if (response.statusCode != 200) {
      debugPrint("getUserAttendance ERROR Body: ${response.body}");
      return [];
    }

    final body = jsonDecode(response.body);
    if (body is! List) return [];

    return body
        .map((e) => AttendanceModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // NEW: ambil student-courses untuk user (mengembalikan ScheduleModel list)
  Future<List<ScheduleModel>> getStudentCourses(String userId) async {
    final url = Uri.parse('$baseUrl/student-courses?user_id=$userId');

    final response = await http.get(url, headers: _headers);

    if (response.statusCode != 200) {
      debugPrint("getStudentCourses ERROR Body: ${response.body}");
      return [];
    }

    final body = jsonDecode(response.body);

    // API bisa mengembalikan struktur: { "success": true, "data": [...] }
    // atau langsung list [...]. Kita dukung keduanya.
    List rawList = [];
    if (body is List) {
      rawList = body;
    } else if (body is Map && body['data'] is List) {
      rawList = body['data'];
    } else {
      return [];
    }

    // rawList item harus sesuai struktur yang ScheduleModel.fromJson harapkan
    return rawList
        .map((e) => ScheduleModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
