import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../core/constants/colors.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String time;
  final IconData icon;
  final Color color;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.color,
    this.isRead = false,
  });
}

class NotificationProvider with ChangeNotifier {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Task Reminder',
      body: 'Your "Market Research" task is due in 30 minutes!',
      time: 'Just now',
      icon: IconsaxPlusBold.timer_1,
      color: AppColors.primary,
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      title: 'Achievement Unlocked!',
      body: 'You completed 5 tasks today. Keep it up!',
      time: '2 hours ago',
      icon: IconsaxPlusBold.award,
      color: AppColors.studyTask,
      isRead: false,
    ),
    NotificationItem(
      id: '3',
      title: 'New Feature',
      body: 'You can now sync your tasks across multiple devices.',
      time: 'Yesterday',
      icon: IconsaxPlusBold.refresh,
      color: AppColors.personalTask,
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      title: 'Welcome to TODO App',
      body: 'Start by adding your first project and stay productive!',
      time: '2 days ago',
      icon: IconsaxPlusBold.emoji_happy,
      color: AppColors.workTask,
      isRead: true,
    ),
  ];

  List<NotificationItem> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  bool get hasUnread => unreadCount > 0;

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    bool changed = false;
    for (var n in _notifications) {
      if (!n.isRead) {
        n.isRead = true;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  void addNotification({
    required String title,
    required String body,
    required IconData icon,
    required Color color,
  }) {
    _notifications.insert(0, NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      time: 'Just now',
      icon: icon,
      color: color,
    ));
    notifyListeners();
  }
}
