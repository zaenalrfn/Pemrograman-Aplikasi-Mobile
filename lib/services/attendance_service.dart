import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/attendance_history_model.dart';
import '../models/schedule_model.dart'; // <- tambah ini

class AttendanceService {
  final String? baseUrl = dotenv.env['API_BASE'];
  final storage = const FlutterSecureStorage();

  AttendanceService();

  Future<Map<String, String>> get _headers async {
    final token = await storage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // existing methods...
  Future<List<CourseModel>> getAllCourses() async {
    final url = Uri.parse('$baseUrl/courses');
    final headers = await _headers;

    final response = await http.get(url, headers: headers);

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
    final headers = await _headers;

    final response = await http.get(url, headers: headers);

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
    final headers = await _headers;

    final response = await http.get(url, headers: headers);

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

  // NEW: Submit attendance
  Future<bool> performAttendance({
    required String userId,
    required String courseId,
    required String tanggal,
    required String status,
    required String method,
    String? photoCapture,
    bool verified = false,
  }) async {
    final url = Uri.parse('$baseUrl/attendances');
    final headers = await _headers;

    final body = jsonEncode({
      'user_id': userId,
      'course_id': courseId,
      'tanggal': tanggal,
      'status': status,
      'method': method,
      'photo_capture': photoCapture,
      'verified': verified,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        return true;
      } else {
        debugPrint(
          "performAttendance ERROR: ${response.statusCode} - ${response.body}",
        );
        return false;
      }
    } catch (e) {
      debugPrint("performAttendance EXCEPTION: $e");
      return false;
    }
  }
}
