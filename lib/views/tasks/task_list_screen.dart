import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:todo_app/views/tasks/add_task_screen.dart';
import '../../core/constants/colors.dart';
import '../../widgets/decorative_background.dart';
import '../../services/task_provider.dart';
import '../notifications/notifications_screen.dart';
import '../../services/notification_service.dart';
import '../../services/notification_provider.dart';

class TaskListScreen extends StatefulWidget {
  final bool isNested;
  final VoidCallback? onBack;
  const TaskListScreen({super.key, this.isNested = false, this.onBack});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late int _selectedDateIndex;
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'To do', 'In Progress', 'Complete'];
  late List<DateTime> _dates;

  @override
  void initState() {
    super.initState();
    _generateDates();
  }

  void _generateDates() {
    final now = DateTime.now();
    // Generate 7 days: 3 before today, today, 3 after today
    _dates = List.generate(7, (i) {
      return DateTime(now.year, now.month, now.day - 3 + i);
    });
    _selectedDateIndex = 3; // today is at index 3
  }

  @override
  Widget build(BuildContext context) {
    Widget taskContent = Column(
      children: [
        if (widget.isNested) ...[
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Stylish back arrow
                GestureDetector(
                  onTap: () {
                    if (widget.onBack != null) {
                      widget.onBack!();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      IconsaxPlusLinear.arrow_left,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Today\'s Tasks',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                Consumer<NotificationProvider>(
                  builder: (context, notificationProvider, _) => Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotificationsScreen(),
                              ),
                            );
                          },
                          child: const Icon(
                            IconsaxPlusBold.notification,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (notificationProvider.hasUnread)
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 8,
                              minHeight: 8,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        const SizedBox(height: 10),
        _buildDateSelector(),
        const SizedBox(height: 30),
        _buildFilterChips(),
        const SizedBox(height: 24),
        Expanded(child: _buildTasksList()),
      ],
    );

    if (widget.isNested) {
      return taskContent;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Today\'s Tasks',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, _) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(IconsaxPlusBold.notification, size: 24),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
                if (notificationProvider.hasUnread)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: DecorativeBackground(child: taskContent),
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
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _dates.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedDateIndex == index;
          final date = _dates[index];
          final dayStr = date.day.toString();
          final weekdayStr = DateFormat('E').format(date); // Mon, Tue, etc.
          final monthStr = DateFormat('MMM').format(date); // Jan, Feb, etc.
          final isToday = _isToday(date);
          return GestureDetector(
            onTap: () => setState(() => _selectedDateIndex = index),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    monthStr,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white70
                          : AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    dayStr,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isToday ? 'Today' : weekdayStr,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white70
                          : AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: _filters.map((filter) {
          bool isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade200,
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTasksList() {
    final taskProvider = Provider.of<TaskProvider>(context);
    final allTasks = taskProvider.tasks;

    // Mapping filter name to status in model
    String? targetStatus;
    if (_selectedFilter == 'To do') {
      targetStatus = 'To-do';
    } else if (_selectedFilter == 'In Progress') {
      targetStatus = 'In Progress';
    } else if (_selectedFilter == 'Complete') {
      targetStatus = 'Done';
    }

    final selectedDate = _dates[_selectedDateIndex];

    final filteredTasks = allTasks.where((task) {
      bool matchesStatus = targetStatus == null || task.status == targetStatus;
      // Filter by selected date: check if the task's start_time falls on the selected day
      bool matchesDate =
          task.startTime.year == selectedDate.year &&
          task.startTime.month == selectedDate.month &&
          task.startTime.day == selectedDate.day;
      return matchesStatus && matchesDate;
    }).toList();

    if (taskProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredTasks.isEmpty) {
      final dateLabel = _isToday(selectedDate)
          ? 'today'
          : DateFormat('MMM d').format(selectedDate);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks for $dateLabel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add a task',
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        return _buildTaskItem(
          task.id,
          task.category, // Assuming category corresponds to project label
          task.title,
          DateFormat('hh:mm a').format(task.startTime),
          task.status,
          _getCategoryColor(task.category),
        );
      },
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

  Widget _buildTaskItem(
    String id,
    String project,
    String task,
    String time,
    String status,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  task,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, color: AppColors.textSecondary),
                onSelected: (value) async {
                  if (value == 'delete') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Task'),
                        content: const Text(
                          'Are you sure you want to delete this task?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && mounted) {
                      final success = await Provider.of<TaskProvider>(
                        context,
                        listen: false,
                      ).deleteTask(id);
                      if (success && mounted) {
                        // Cancel notification
                        NotificationService().cancelNotification(id.hashCode);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Task deleted successfully'),
                          ),
                        );
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to delete task'),
                          ),
                        );
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                time,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  final taskProvider = Provider.of<TaskProvider>(
                    context,
                    listen: false,
                  );
                  final nextStatus = taskProvider.getNextStatus(status);
                  final success = await taskProvider.updateTaskStatus(
                    id,
                    nextStatus,
                  );
                  if (success && mounted) {
                    if (nextStatus == 'Done') {
                      NotificationService().cancelNotification(id.hashCode);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Status changed to $nextStatus')),
                    );
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _getStatusColor(status).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        status,
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.swap_horiz_rounded,
                        size: 12,
                        color: _getStatusColor(status),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Done':
        return AppColors.success;
      case 'In Progress':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
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
            IconButton(
              icon: const Icon(
                Icons.home_filled,
                size: 28,
                color: AppColors.textSecondary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            IconButton(
              icon: const Icon(
                Icons.calendar_month_rounded,
                size: 28,
                color: AppColors.primary,
              ),
              onPressed: () {},
            ),
            const SizedBox(width: 48),
            IconButton(
              icon: const Icon(
                Icons.insert_drive_file_rounded,
                size: 28,
                color: AppColors.textSecondary,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(
                Icons.group_rounded,
                size: 28,
                color: AppColors.textSecondary,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
