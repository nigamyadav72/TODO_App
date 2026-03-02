import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../core/constants/colors.dart';
import '../../services/auth_provider.dart';
import '../../services/task_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 30),

          // --- User Avatar & Info ---
          _buildProfileHeader(context, auth),
          const SizedBox(height: 30),

          // --- Stats Row ---
          _buildStatsRow(taskProvider),
          const SizedBox(height: 30),

          // --- Menu Items ---
          _buildMenuSection(context, auth),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with first letter
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
            ),
            child: Center(
              child: Text(
                auth.userName.isNotEmpty ? auth.userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  auth.userEmail,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Text(
                    'PRO MEMBER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(TaskProvider taskProvider) {
    return Row(
      children: [
        _buildStatCard('Total', taskProvider.totalTasks.toString(), IconsaxPlusLinear.document_text_1, AppColors.primary),
        const SizedBox(width: 12),
        _buildStatCard('Done', taskProvider.completedTasks.toString(), IconsaxPlusLinear.tick_circle, AppColors.success),
        const SizedBox(width: 12),
        _buildStatCard('Pending', taskProvider.todoCount.toString(), IconsaxPlusLinear.clock, AppColors.warning),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, AuthProvider auth) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: IconsaxPlusLinear.user,
            title: 'Account Details',
            subtitle: auth.userEmail,
            color: AppColors.primary,
            onTap: () => _showAccountDetails(context, auth),
          ),
          _divider(),
          _buildMenuItem(
            icon: IconsaxPlusLinear.notification,
            title: 'Notifications',
            subtitle: 'Manage notifications',
            color: AppColors.warning,
            onTap: () => _showComingSoon(context, 'Notifications'),
          ),
          _divider(),
          _buildMenuItem(
            icon: IconsaxPlusLinear.info_circle,
            title: 'Help & Support',
            subtitle: 'FAQs, guides, and more',
            color: AppColors.personalTask,
            onTap: () => _showHelpSupport(context),
          ),
          _divider(),
          _buildMenuItem(
            icon: IconsaxPlusLinear.message_2,
            title: 'Contact Us',
            subtitle: 'support@todoapp.com',
            color: AppColors.success,
            onTap: () => _showContactUs(context),
          ),
          _divider(),
          _buildMenuItem(
            icon: IconsaxPlusLinear.document,
            title: 'About',
            subtitle: 'Version 1.0.0',
            color: AppColors.textSecondary,
            onTap: () => _showAbout(context),
          ),
          _divider(),
          _buildMenuItem(
            icon: IconsaxPlusLinear.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            color: AppColors.error,
            onTap: () => _handleLogout(context, auth),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: title == 'Logout' ? AppColors.error : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: Colors.grey.shade100),
    );
  }

  // --- Dialog Handlers ---

  void _showAccountDetails(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                auth.userName.isNotEmpty ? auth.userName[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(auth.userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(auth.userEmail, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            _detailRow(IconsaxPlusLinear.user, 'Username', auth.userName),
            const SizedBox(height: 12),
            _detailRow(IconsaxPlusLinear.message, 'Email', auth.userEmail),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  void _showHelpSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Help & Support', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _helpItem(IconsaxPlusLinear.book, 'Getting Started', 'Learn how to create and manage tasks'),
            const SizedBox(height: 12),
            _helpItem(IconsaxPlusLinear.refresh_2, 'Changing Task Status', 'Tap the status badge on any task to cycle through To-do → In Progress → Done'),
            const SizedBox(height: 12),
            _helpItem(IconsaxPlusLinear.calendar, 'Date Filtering', 'Use the date selector to view tasks for a specific day'),
            const SizedBox(height: 12),
            _helpItem(IconsaxPlusLinear.people, 'Task Groups', 'Tasks are grouped by their category (Work, Personal, etc.)'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _helpItem(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showContactUs(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Contact Us', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _contactItem(IconsaxPlusLinear.sms, 'Email', 'support@todoapp.com'),
            const SizedBox(height: 12),
            _contactItem(IconsaxPlusLinear.call, 'Phone', '+977 98XXXXXXXX'),
            const SizedBox(height: 12),
            _contactItem(IconsaxPlusLinear.global, 'Website', 'www.todoapp.com'),
            const SizedBox(height: 12),
            _contactItem(IconsaxPlusLinear.location, 'Address', 'Kathmandu, Nepal'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _contactItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('About Todo App'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0'),
            SizedBox(height: 8),
            Text(
              'A beautiful task management app designed to help you stay productive and organized.',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
            SizedBox(height: 12),
            Text('Built with Flutter ❤️', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context, AuthProvider auth) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      auth.logout();
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon!')),
    );
  }
}
