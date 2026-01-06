import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/app_version_model.dart';
import 'package:flutter/material.dart';

class AppVersionService {
  final String? baseUrl = dotenv.env['API_BASE'];

  Future<List<AppVersion>> getAppVersions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/app-versions'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['data'];
        return list.map((e) => AppVersion.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load app versions');
      }
    } catch (e) {
      debugPrint('Error fetching app versions: $e');
      rethrow;
    }
  }

  Future<AppVersion?> checkUpdate(String platform) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/check-update?platform=$platform'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          return AppVersion.fromJson(data['data']);
        }
        return null;
      } else {
        throw Exception('Failed to check checks');
      }
    } catch (e) {
      debugPrint('Error checking update: $e');
      return null;
    }
  }
}
