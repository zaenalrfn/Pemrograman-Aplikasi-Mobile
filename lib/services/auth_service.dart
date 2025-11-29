import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  final storage = const FlutterSecureStorage();
  final String baseUrl = 'http://operasional_absensi_mahasiswa.test/api';

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = UserModel.fromJson(data['user']);
      final token = data['token'];

      // simpan token & user di storage
      await storage.write(key: 'token', value: token);
      await storage.write(key: 'user', value: jsonEncode(data['user']));

      return {'user': user, 'token': token};
    }
    return null;
  }

  Future<void> logout(String token) async {
    await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    await storage.delete(key: 'token');
    await storage.delete(key: 'user');
  }

  Future<Map<String, dynamic>?> loadUser() async {
    final token = await storage.read(key: 'token');
    final userJson = await storage.read(key: 'user');

    if (token != null && userJson != null) {
      final user = UserModel.fromJson(jsonDecode(userJson));
      return {'user': user, 'token': token};
    }
    return null;
  }
}
