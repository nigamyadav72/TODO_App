import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api'; // Use 10.0.2.2 for Android Emulator, 127.0.0.1 for iOS Simulator

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        body: jsonEncode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Task>> getTasks() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/tasks/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((item) => Task.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> createTask(Task task) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/tasks/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode(task.toJson()),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
