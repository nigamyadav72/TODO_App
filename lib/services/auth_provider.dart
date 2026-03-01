import 'package:flutter/material.dart';
import 'api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isChecking = true;

  bool get isAuthenticated => _isAuthenticated;
  bool get isChecking => _isChecking;

  AuthProvider() {
    checkAuth();
  }

  Future<void> checkAuth() async {
    _isChecking = true;
    notifyListeners();

    final token = await ApiService.getToken();
    _isAuthenticated = token != null;
    
    _isChecking = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final success = await ApiService.login(email, password);
    if (success) {
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
