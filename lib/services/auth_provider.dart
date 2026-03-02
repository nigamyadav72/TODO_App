import 'package:flutter/material.dart';
import 'api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isChecking = true;
  String _userName = 'User';
  String _userEmail = '';

  bool get isAuthenticated => _isAuthenticated;
  bool get isChecking => _isChecking;
  String get userName => _userName;
  String get userEmail => _userEmail;

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

  Future<bool> login(String email, String password) async {
    final success = await ApiService.login(email, password);
    if (success) {
      final userInfo = await ApiService.getUserInfo();
      _userName = userInfo['name'] ?? 'User';
      _userEmail = userInfo['email'] ?? '';
      _isAuthenticated = true;
      notifyListeners();
    }
    return success;
  }

  Future<bool> register(String username, String email, String password) async {
    final success = await ApiService.register(username, email, password);
    if (success) {
      final userInfo = await ApiService.getUserInfo();
      _userName = userInfo['name'] ?? 'User';
      _userEmail = userInfo['email'] ?? '';
      _isAuthenticated = true;
      notifyListeners();
    }
    return success;
  }

  Future<void> logout() async {
    await ApiService.logout();
    _isAuthenticated = false;
    notifyListeners();
  }
}
