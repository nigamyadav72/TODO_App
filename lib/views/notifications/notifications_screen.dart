import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../core/constants/colors.dart';
import '../../widgets/decorative_background.dart';
import '../../services/notification_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final notifications = notificationProvider.notifications;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(IconsaxPlusLinear.arrow_left_2),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () => notificationProvider.markAllAsRead(),
              child: const Text('Mark all as read'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: DecorativeBackground(
        child: notifications.isEmpty
            ? _buildEmptyState()
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: notifications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return GestureDetector(
                    onTap: () => notificationProvider.markAsRead(notification.id),
                    child: _buildNotificationItem(notification),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            IconsaxPlusLinear.notification,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.2),
          ),
          const SizedBox(height: 20),
          const Text(
            'No new notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "We'll notify you when something important happens.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : AppColors.primary.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: notification.isRead ? Colors.grey.shade100 : AppColors.primary.withOpacity(0.1),
        ),
        boxShadow: [
          if (!notification.isRead)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: notification.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(notification.icon, color: notification.color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      notification.time,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notification.body,
                  style: TextStyle(
                    color: AppColors.textPrimary.withOpacity(0.7),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
