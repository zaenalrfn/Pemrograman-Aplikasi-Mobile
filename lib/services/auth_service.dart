import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final String baseUrl = 'http://192.168.222.58:8000/api';

  /// Login dan simpan token + user ke FlutterSecureStorage.
  /// Meng-handle beberapa format token yang umum dikembalikan backend.
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // debug: lihat struktur response (hapus/komentari pada produksi)
      debugPrint('Login response raw: $data');

      // detect token di beberapa field umum
      String? token;
      if (data is Map<String, dynamic>) {
        token =
            data['token'] as String? ??
            data['access_token'] as String? ??
            // jika backend membungkus token di data.user atau data.meta
            (data['data'] is Map ? (data['data']['token'] as String?) : null) ??
            // Laravel Sanctum personal access uses plainTextToken when using createToken()
            data['plainTextToken'] as String?;
      }

      // Jika respons berisi objek { user: {...}, token: '...' } atau { user: {...}, access_token: '...' }
      // Atau respons mengandung `user` di dalam `data`
      Map<String, dynamic>? userMap;
      if (data['user'] is Map<String, dynamic>) {
        userMap = Map<String, dynamic>.from(data['user']);
      } else if (data['data'] is Map<String, dynamic> &&
          data['data']['user'] is Map<String, dynamic>) {
        userMap = Map<String, dynamic>.from(data['data']['user']);
      } else if (data is Map<String, dynamic> &&
          data.containsKey('name') &&
          data.containsKey('email')) {
        // kalau backend langsung mengembalikan user object tanpa wrapping
        userMap = Map<String, dynamic>.from(data);
      }

      if (token == null) {
        // coba cek field nested lain (safety)
        debugPrint(
          'Warning: login response tidak mengandung token yang dikenali.',
        );
        // Namun jika backend memakai cookie/session, mobile sebaiknya meminta endpoint token-based.
      }

      if (userMap == null) {
        debugPrint(
          'Warning: login response tidak mengandung objek user yang dikenali.',
        );
      }

      // simpan token dan user (jika ada)
      if (token != null) {
        await storage.write(key: 'token', value: token);
        debugPrint(
          'Saved token: ${token.substring(0, token.length > 8 ? 8 : token.length)}...',
        ); // partial print
      }

      if (userMap != null) {
        await storage.write(key: 'user', value: jsonEncode(userMap));
      }

      final user = userMap != null ? UserModel.fromJson(userMap) : null;
      return {'user': user, 'token': token};
    }

    // bisa tambahkan debug pada failure
    debugPrint('Login failed: ${response.statusCode} - ${response.body}');
    return null;
  }

  /// Logout: panggil endpoint logout (jika tersedia) lalu hapus storage.
  /// Jika token tidak diberikan, ambil dari storage.
  Future<void> logout([String? token]) async {
    final tokenToUse = token ?? await storage.read(key: 'token');

    try {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (tokenToUse != null && tokenToUse.isNotEmpty)
            'Authorization': 'Bearer $tokenToUse',
        },
      );
    } catch (e) {
      debugPrint('Logout request error: $e');
      // tetap lanjut untuk hapus storage
    } finally {
      await storage.delete(key: 'token');
      await storage.delete(key: 'user');
    }
  }

  /// Load user & token dari secure storage
  Future<Map<String, dynamic>?> loadUser() async {
    final token = await storage.read(key: 'token');
    final userJson = await storage.read(key: 'user');

    if (token != null && token.isNotEmpty && userJson != null) {
      final user = UserModel.fromJson(jsonDecode(userJson));
      return {'user': user, 'token': token};
    }
    return null;
  }
}
