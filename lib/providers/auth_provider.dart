import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  String? _token;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _user != null && _token != null;

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

  Future<void> logout() async {
    if (_token != null) await _authService.logout(_token!);
    _user = null;
    _token = null;
    notifyListeners();
  }

  Future<void> loadUserFromStorage() async {
    final stored = await _authService.loadUser();
    if (stored != null) {
      _user = stored['user'] as UserModel;
      _token = stored['token'] as String;
      notifyListeners();
    }
  }
}
