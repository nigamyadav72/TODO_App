import 'package:flutter/material.dart';
import 'api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isChecking = true;
  String _userName = 'User';
  String _userEmail = '';
  String? _lastError;

  bool get isAuthenticated => _isAuthenticated;
  bool get isChecking => _isChecking;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String? get lastError => _lastError;

  AuthProvider() {
    checkAuth();
  }

  Future<void> checkAuth() async {
    _isChecking = true;
    notifyListeners();

    final token = await ApiService.getToken();
    if (token != null) {
      final userInfo = await ApiService.getUserInfo();
      _userName = userInfo['name'] ?? 'User';
      _userEmail = userInfo['email'] ?? '';
      _isAuthenticated = true;
    } else {
      _isAuthenticated = false;
    }
    
    _isChecking = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _lastError = null;
    final result = await ApiService.login(email, password);
    if (result['success'] == true) {
      final userInfo = await ApiService.getUserInfo();
      _userName = userInfo['name'] ?? 'User';
      _userEmail = userInfo['email'] ?? '';
      _isAuthenticated = true;
      notifyListeners();
    } else {
      _lastError = result['error'] ?? 'Login failed.';
    }
    return result;
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    _lastError = null;
    final result = await ApiService.register(username, email, password);
    if (result['success'] == true) {
      final userInfo = await ApiService.getUserInfo();
      _userName = userInfo['name'] ?? 'User';
      _userEmail = userInfo['email'] ?? '';
      _isAuthenticated = true;
      notifyListeners();
    } else {
      _lastError = result['error'] ?? 'Registration failed.';
    }
    return result;
  }

  Future<void> logout() async {
    await ApiService.logout();
    _isAuthenticated = false;
    _lastError = null;
    notifyListeners();
  }
}
