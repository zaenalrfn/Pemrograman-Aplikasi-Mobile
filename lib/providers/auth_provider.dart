import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  String? _token;
  bool _isInitialized = false;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _user != null && _token != null;
  bool get isInitialized => _isInitialized;

  Future<bool> login(String email, String password) async {
    final result = await _authService.login(email, password);
    if (result != null) {
      _user = result['user'] as UserModel;
      _token = result['token'] as String;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> updatePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    if (_token == null) {
      return {
        'success': false,
        'message': 'Token tidak ditemukan. Silakan login ulang.',
      };
    }
    return await _authService.updatePassword(
      _token!,
      currentPassword,
      newPassword,
      confirmPassword,
    );
  }

  Future<void> logout() async {
    if (_token != null) await _authService.logout(_token!);
    _user = null;
    _token = null;
    notifyListeners();
  }

  Future<void> loadUserFromStorage() async {
    try {
      final stored = await _authService.loadUser();
      if (stored != null) {
        _user = stored['user'] as UserModel;
        _token = stored['token'] as String;
      }
    } catch (e) {
      debugPrint('Error loading user from storage: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }
}
