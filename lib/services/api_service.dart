import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  static String get baseUrl => 'https://todo-app-x5nq.onrender.com/api';

  // Render free-tier can take up to 60s to wake from cold start
  static const Duration _timeout = Duration(seconds: 60);
  static const int _maxRetries = 2;

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Helper: makes an HTTP request with timeout and retry for cold-start resilience.
  static Future<http.Response> _requestWithRetry(
    Future<http.Response> Function() requestFn,
  ) async {
    int attempt = 0;
    while (true) {
      try {
        final response = await requestFn().timeout(_timeout);
        return response;
      } on TimeoutException {
        attempt++;
        if (attempt >= _maxRetries) {
          throw ApiException(
            'Server is taking too long to respond. It may be waking up from sleep — please try again in a moment.',
          );
        }
        debugPrint('Request timed out, retrying (attempt $attempt/$_maxRetries)...');
        // Wait a bit before retry
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        if (e is ApiException) rethrow;
        attempt++;
        if (attempt >= _maxRetries) {
          throw ApiException(
            'Network error: Unable to connect to server. Please check your internet connection and try again.',
          );
        }
        debugPrint('Request error: $e, retrying (attempt $attempt/$_maxRetries)...');
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _requestWithRetry(() => http.post(
        Uri.parse('$baseUrl/auth/login/'),
        body: jsonEncode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        if (data['user'] != null) {
          await prefs.setString('user_name', data['user']['username'] ?? '');
          await prefs.setString('user_email', data['user']['email'] ?? '');
        }
        return {'success': true};
      } else {
        final body = jsonDecode(response.body);
        final errorMsg = body['error'] ?? 'Invalid email or password.';
        debugPrint('Login failed with status: ${response.statusCode} — $errorMsg');
        return {'success': false, 'error': errorMsg};
      }
    } on ApiException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      debugPrint('Login exception: $e');
      return {'success': false, 'error': 'Connection error. Please check your internet and try again.'};
    }
  }

  static Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await _requestWithRetry(() => http.post(
        Uri.parse('$baseUrl/auth/register/'),
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      ));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        if (data['user'] != null) {
          await prefs.setString('user_name', data['user']['username'] ?? '');
          await prefs.setString('user_email', data['user']['email'] ?? '');
        }
        return {'success': true};
      } else {
        final body = jsonDecode(response.body);
        String errorMsg = 'Registration failed.';
        if (body is Map) {
          if (body.containsKey('error')) {
            errorMsg = body['error'];
          } else if (body.containsKey('email')) {
            errorMsg = 'This email is already registered.';
          } else if (body.containsKey('username')) {
            errorMsg = 'This username is already taken.';
          } else if (body.containsKey('password')) {
            final passwordErrors = body['password'];
            if (passwordErrors is List && passwordErrors.isNotEmpty) {
              errorMsg = passwordErrors.first;
            }
          }
        }
        return {'success': false, 'error': errorMsg};
      }
    } on ApiException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      debugPrint('Register exception: $e');
      return {'success': false, 'error': 'Connection error. Please check your internet and try again.'};
    }
  }

  static Future<List<Task>> getTasks() async {
    try {
      final token = await getToken();
      if (token == null) return [];

      final response = await _requestWithRetry(() => http.get(
        Uri.parse('$baseUrl/tasks/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      ));

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((item) => Task.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        // Token is invalid/expired — clear it
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        throw ApiException('Session expired. Please login again.', statusCode: 401);
      }
      return [];
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('getTasks error: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> createTask(Task task) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not logged in. Please login first.'};
      }

      final taskJson = task.toJson();
      debugPrint('Creating task with data: $taskJson');

      final response = await _requestWithRetry(() => http.post(
        Uri.parse('$baseUrl/tasks/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode(taskJson),
      ));

      debugPrint('Create task response: ${response.statusCode} — ${response.body}');

      if (response.statusCode == 201) {
        return {
          'success': true,
          'task': Task.fromJson(jsonDecode(response.body)),
        };
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        return {'success': false, 'error': 'Session expired. Please login again.'};
      } else {
        // Parse the error response for a meaningful message
        String errorMsg = 'Failed to create task.';
        try {
          final body = jsonDecode(response.body);
          if (body is Map) {
            // DRF returns field-level errors like {"group": ["Invalid pk..."]}.
            final errors = <String>[];
            body.forEach((key, value) {
              if (value is List) {
                errors.add('$key: ${value.join(", ")}');
              } else {
                errors.add('$key: $value');
              }
            });
            if (errors.isNotEmpty) errorMsg = errors.join('\n');
          }
        } catch (_) {}
        debugPrint('Create task failed: $errorMsg');
        return {'success': false, 'error': errorMsg};
      }
    } on ApiException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      debugPrint('Create task exception: $e');
      return {'success': false, 'error': 'Connection error. Please try again.'};
    }
  }

  static Future<bool> deleteTask(String id) async {
    try {
      final token = await getToken();
      final response = await _requestWithRetry(() => http.delete(
        Uri.parse('$baseUrl/tasks/$id/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      ));

      return response.statusCode == 204;
    } catch (e) {
      debugPrint('Delete task error: $e');
      return false;
    }
  }

  static Future<bool> updateTaskStatus(String id, String status) async {
    try {
      final token = await getToken();
      final response = await _requestWithRetry(() => http.patch(
        Uri.parse('$baseUrl/tasks/$id/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode({'status': status}),
      ));

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
