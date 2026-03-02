import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../widgets/decorative_background.dart';
import '../../services/task_provider.dart';
import '../../services/auth_provider.dart';
import '../tasks/task_list_screen.dart';
import '../tasks/add_task_screen.dart';

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
              const TaskListScreen(isNested: true),
              const Center(child: Text('Projects View', style: TextStyle(fontSize: 20))),
              const Center(child: Text('Groups View', style: TextStyle(fontSize: 20))),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
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
        const CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d'),
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
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 24),
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
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
            if (confirmed == true && mounted) {
              Provider.of<AuthProvider>(context, listen: false).logout();
            }
          },
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, size: 28),
              onPressed: () {},
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.all(4),
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
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
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
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: inProgressTasks.length,
        itemBuilder: (context, index) {
          final task = inProgressTasks[index];
          return _buildInProgressCard(
            task.category,
            task.title,
            _getCategoryColor(task.category),
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

  Widget _buildInProgressCard(String label, String title, Color color) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const Spacer(),
              Icon(Icons.more_horiz, color: AppColors.textSecondary, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
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
        color: AppColors.bottomBarBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        notchMargin: 12,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavIcon(Icons.home_filled, 0),
            _buildNavIcon(Icons.calendar_month_rounded, 1),
            const SizedBox(width: 48),
            _buildNavIcon(Icons.insert_drive_file_rounded, 2),
            _buildNavIcon(Icons.group_rounded, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    bool isSelected = _currentIndex == index;
    return IconButton(
      icon: Icon(
        icon,
        size: 28,
        color: isSelected ? AppColors.primary : AppColors.textSecondary.withOpacity(0.5),
      ),
      onPressed: () => setState(() => _currentIndex = index),
    );
  }
}
