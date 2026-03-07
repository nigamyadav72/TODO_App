import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  List<Task> get todayTasks {
    final now = DateTime.now();
    return _tasks.where((t) {
      final date = t.startTime.toLocal();
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).toList();
  }

  int get todayTasksCount => todayTasks.length;
  int get todayCompletedCount => todayTasks.where((t) => t.status == 'Done').length;
  double get todayProgress => todayTasksCount == 0 ? 0 : todayCompletedCount / todayTasksCount;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> fetchTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final token = await ApiService.getToken();
    if (token == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _tasks = await ApiService.getTasks();
    } on ApiException catch (e) {
      _error = e.message;
      debugPrint('Error fetching tasks: $e');
    } catch (e) {
      _error = 'Failed to load tasks. Pull down to retry.';
      debugPrint('Error fetching tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> addTask(Task task) async {
    final result = await ApiService.createTask(task);
    if (result['success'] == true) {
      await fetchTasks();
      return result;
    }
    return result;
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
