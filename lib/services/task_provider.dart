import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  // --- Computed stats for dashboard ---

  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((t) => t.status == 'Done').length;
  int get inProgressCount => _tasks.where((t) => t.status == 'In Progress').length;
  int get todoCount => _tasks.where((t) => t.status == 'To-do').length;

  double get overallProgress => totalTasks == 0 ? 0 : completedTasks / totalTasks;

  List<Task> get inProgressTasks => _tasks.where((t) => t.status == 'In Progress').toList();

  /// Returns a list of unique categories with their task count and completion ratio.
  List<Map<String, dynamic>> get categoryStats {
    final Map<String, List<Task>> grouped = {};
    for (final task in _tasks) {
      grouped.putIfAbsent(task.category, () => []).add(task);
    }
    return grouped.entries.map((entry) {
      final total = entry.value.length;
      final done = entry.value.where((t) => t.status == 'Done').length;
      return {
        'name': entry.key,
        'total': total,
        'done': done,
        'progress': total == 0 ? 0.0 : done / total,
      };
    }).toList();
  }

  Future<void> fetchTasks() async {
    final token = await ApiService.getToken();
    if (token == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _tasks = await ApiService.getTasks();
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTask(Task task) async {
    bool success = await ApiService.createTask(task);
    if (success) {
      await fetchTasks();
    }
    return success;
  }

  Future<bool> deleteTask(String id) async {
    bool success = await ApiService.deleteTask(id);
    if (success) {
      await fetchTasks();
    }
    return success;
  }

  Future<bool> updateTaskStatus(String id, String newStatus) async {
    bool success = await ApiService.updateTaskStatus(id, newStatus);
    if (success) {
      await fetchTasks();
    }
    return success;
  }

  /// Cycles status: To-do → In Progress → Done → To-do
  String getNextStatus(String current) {
    switch (current) {
      case 'To-do':
        return 'In Progress';
      case 'In Progress':
        return 'Done';
      case 'Done':
        return 'To-do';
      default:
        return 'To-do';
    }
  }
}
