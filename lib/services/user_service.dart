import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserService {
  final String baseUrl;

  UserService({required this.baseUrl});

  Future<UserModel?> getCurrentUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/current-user'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return UserModel.fromMap(data);
    } catch (e) {
      print("Error getCurrentUser: $e");
      return null;
    }
  }
}
