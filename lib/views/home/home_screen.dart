import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../core/constants/colors.dart';
import '../../widgets/decorative_background.dart';
import '../../services/task_provider.dart';
import '../../services/auth_provider.dart';
import '../tasks/task_list_screen.dart';
import '../tasks/add_task_screen.dart';
import '../projects/projects_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).fetchTasks();
    });
  }
  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: DecorativeBackground(
        child: SafeArea(
          child: IndexedStack(
            index: _currentIndex, // Limit for now if placeholder
            children: [
              _buildDashboard(taskProvider),
              TaskListScreen(
                isNested: true,
                onBack: () => setState(() => _currentIndex = 0),
              ),
              const ProjectsScreen(),
              const ProfileScreen(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddTaskScreen()),
            );
          },
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildDashboard(TaskProvider taskProvider) {
    final categories = taskProvider.categoryStats;
    return RefreshIndicator(
      onRefresh: () => taskProvider.fetchTasks(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildHeader(),
            const SizedBox(height: 30),
            _buildTodayTaskCard(taskProvider),
            const SizedBox(height: 30),
            _buildSectionHeader('In Progress', count: taskProvider.inProgressCount, onSeeAll: () {
              setState(() => _currentIndex = 1);
            }),
            const SizedBox(height: 16),
            _buildInProgressList(taskProvider),
            const SizedBox(height: 30),
            _buildSectionHeader('Task Groups', count: categories.length),
            const SizedBox(height: 16),
            _buildTaskGroupsList(taskProvider),
            const SizedBox(height: 110),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Consumer<AuthProvider>(
          builder: (context, auth, _) => GestureDetector(
            onTap: () => setState(() => _currentIndex = 3),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: Text(
                auth.userName.isNotEmpty ? auth.userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Consumer<AuthProvider>(
              builder: (context, auth, _) => Text(
                auth.userName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const Spacer(),
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                IconsaxPlusBold.notification,
                size: 24,
                color: AppColors.textPrimary,
              ),
            ),
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodayTaskCard(TaskProvider taskProvider) {
    final total = taskProvider.totalTasks;
    final done = taskProvider.completedTasks;
    final percent = taskProvider.overallProgress;
    final percentInt = (percent * 100).toInt();

    String message;
    if (total == 0) {
      message = 'No tasks yet.\nAdd some tasks!';
    } else if (percent >= 1.0) {
      message = 'All tasks done!\nGreat job!';
    } else if (percent >= 0.5) {
      message = 'Your tasks are\nalmost done!';
    } else {
      message = 'You have $total tasks.\n$done completed so far.';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(32),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _currentIndex = 1);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size(120, 45),
                    elevation: 0,
                  ),
                  child: const Text('View Task'),
                ),
              ],
            ),
          ),
          CircularPercentIndicator(
            radius: 45.0,
            lineWidth: 8.0,
            percent: percent.clamp(0.0, 1.0),
            center: Text(
              '$percentInt%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            progressColor: Colors.white,
            backgroundColor: Colors.white.withOpacity(0.3),
            circularStrokeCap: CircularStrokeCap.round,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll, int? count}) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (count != null) ...[
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
        const Spacer(),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text('See All'),
          ),
      ],
    );
  }

  Widget _buildInProgressList(TaskProvider taskProvider) {
    final inProgressTasks = taskProvider.inProgressTasks;

    if (inProgressTasks.isEmpty) {
      return SizedBox(
        height: 140,
        child: Center(
          child: Text(
            'No tasks in progress',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ),
      );
    }

    return SizedBox(
      height: 155, // Increased height for better shadow and padding
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4), // Padding for shadow
        itemCount: inProgressTasks.length,
        itemBuilder: (context, index) {
          final task = inProgressTasks[index];
          return _buildInProgressCard(
            task.category,
            task.title,
            _getCategoryColor(task.category),
            _getCategoryIcon(task.category),
          );
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Work':
        return AppColors.workTask;
      case 'Personal':
        return AppColors.personalTask;
      case 'Daily Study':
        return AppColors.studyTask;
      default:
        return Colors.purple;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Work':
        return Icons.work_outline;
      case 'Personal':
        return Icons.person_outline;
      case 'Daily Study':
        return Icons.book_outlined;
      default:
        return Icons.folder_outlined;
    }
  }

  Widget _buildInProgressCard(String label, String title, Color color, IconData icon) {
    return Container(
      width: 210,
      margin: const EdgeInsets.only(right: 16, bottom: 8, top: 2),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withOpacity(0.12), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textPrimary.withOpacity(0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(IconsaxPlusLinear.more, color: AppColors.textSecondary, size: 16),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskGroupsList(TaskProvider taskProvider) {
    final categories = taskProvider.categoryStats;

    if (categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No task groups yet. Add tasks to see groups here.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      children: categories.map((cat) {
        final name = cat['name'] as String;
        final total = cat['total'] as int;
        final progress = (cat['progress'] as double).clamp(0.0, 1.0);
        final color = _getCategoryColor(name);
        final icon = _getCategoryIcon(name);
        return _buildTaskGroupItem(name, total, progress, color, icon);
      }).toList(),
    );
  }

  Widget _buildTaskGroupItem(String name, int taskCount, double progress, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Text(
                  '$taskCount Tasks',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          CircularPercentIndicator(
            radius: 25.0,
            lineWidth: 5.0,
            percent: progress,
            center: Text(
              "${(progress * 100).toInt()}%",
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            progressColor: color,
            backgroundColor: color.withOpacity(0.1),
            circularStrokeCap: CircularStrokeCap.round,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F5FF), // Very light lavender background matching image
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        notchMargin: 12, // Notch margin as per standard CircularNotchedRectangle
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavIcon(IconsaxPlusBold.home_1, 0),
            _buildNavIcon(IconsaxPlusBold.calendar, 1),
            const SizedBox(width: 48),
            _buildNavIcon(IconsaxPlusBold.document, 2),
            _buildNavIcon(IconsaxPlusBold.user, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    bool isSelected = _currentIndex == index;
    // Unselected color is a light lavender purple constant
    final Color unselectedColor = const Color(0xFFB8B0D4);
    
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 50,
        height: 50,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Shadow only for selected icon
            if (isSelected)
              Positioned(
                bottom: 12,
                child: Container(
                  width: 14,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            Icon(
              icon, // Always use bold/filled icon
              size: 26,
              color: AppColors.primary, // Deep purple for all icons (selected or not)
            ),
          ],
        ),
      ),
    );
  }
}
