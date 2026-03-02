import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class ApiService {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    } else {
      return 'http://127.0.0.1:8000/api';
    }
  }

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
        if (data['user'] != null) {
          await prefs.setString('user_name', data['user']['username'] ?? '');
          await prefs.setString('user_email', data['user']['email'] ?? '');
        }
        return true;
      } else {
        debugPrint('Login failed with status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Login exception: $e');
      return false;
    }
  }

  static Future<bool> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/'),
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        if (data['user'] != null) {
          await prefs.setString('user_name', data['user']['username'] ?? '');
          await prefs.setString('user_email', data['user']['email'] ?? '');
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Register exception: $e');
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

  static Future<bool> deleteTask(String id) async {
    try {
      final token = await getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/tasks/$id/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      return response.statusCode == 204;
    } catch (e) {
      debugPrint('Delete task error: $e');
      return false;
    }
  }

  static Future<bool> updateTaskStatus(String id, String status) async {
    try {
      final token = await getToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/tasks/$id/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode({'status': status}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update task status error: $e');
      return false;
    }
  }
  static Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    return true;
  }

  static Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('user_name'),
      'email': prefs.getString('user_email'),
    };
  }
}
