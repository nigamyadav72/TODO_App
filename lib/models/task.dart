class Task {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // 'To-do', 'In Progress', 'Done'
  final String groupId;
  final String category;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.groupId,
    this.category = 'Work',
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(),
      title: json['title'],
      description: json['description'] ?? '',
      startTime: DateTime.parse(json['start_time']).toLocal(),
      endTime: DateTime.parse(json['end_time']).toLocal(),
      status: json['status'],
      groupId: json['group']?.toString() ?? '',
      category: json['category'] ?? 'Work',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'start_time': startTime.toUtc().toIso8601String(),
      'end_time': endTime.toUtc().toIso8601String(),
      'status': status,
      // Send null if groupId is empty — the backend expects a valid integer PK or null
      'group': groupId.isNotEmpty ? int.tryParse(groupId) : null,
      'category': category,
    };
  }
}

class TaskGroup {
  final String id;
  final String name;
  final int totalTasks;
  final int completedTasks;
  final String type; // 'Work', 'Personal', 'Daily'

  TaskGroup({
    required this.id,
    required this.name,
    required this.totalTasks,
    required this.completedTasks,
    required this.type,
  });

  double get progress => totalTasks == 0 ? 0 : completedTasks / totalTasks;
}
