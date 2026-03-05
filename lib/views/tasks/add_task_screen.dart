import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../core/constants/colors.dart';
import '../../widgets/decorative_background.dart';
import '../../services/task_provider.dart';
import '../../models/task.dart';
import '../notifications/notifications_screen.dart';
import '../../services/notification_service.dart';
import '../../services/notification_provider.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  String _selectedGroup = 'Work';
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isSaving = false;

  void _handleSave() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a project name')),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Combine date + optional time
    final startDateTime = DateTime(
      _startDate.year, _startDate.month, _startDate.day,
      _startTime?.hour ?? 0, _startTime?.minute ?? 0,
    );
    final endDateTime = DateTime(
      _endDate.year, _endDate.month, _endDate.day,
      _endTime?.hour ?? 23, _endTime?.minute ?? 59,
    );

    final newTask = Task(
      id: '',
      title: _nameController.text,
      description: _descriptionController.text,
      startTime: startDateTime,
      endTime: endDateTime,
      status: 'To-do',
      groupId: '1',
      category: _selectedGroup,
    );

    final taskResult = await Provider.of<TaskProvider>(
      context,
      listen: false,
    ).addTask(newTask);

    setState(() => _isSaving = false);

    if (!mounted) return;

    if (taskResult != null) {
      // Schedule notification
      NotificationService().scheduleTaskNotification(
        id: taskResult.id.hashCode,
        title: 'Task Reminder',
        body: 'Your project "${taskResult.title}" is due now!',
        scheduledTime: taskResult.startTime,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project added successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add project. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(IconsaxPlusLinear.arrow_left_2),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Project',
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
      body: DecorativeBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdownField(
                'Task Group',
                _selectedGroup,
                ['Work', 'Personal', 'Daily Study', 'Household'],
                (val) => setState(() => _selectedGroup = val!),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                'Project Name',
                _nameController,
                hint: 'Enter project name',
              ),
              const SizedBox(height: 24),
              _buildTextField(
                'Description',
                _descriptionController,
                hint: 'Project description',
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildDateField('Start Date', _startDate, (date) {
                      if (date != null) setState(() => _startDate = date);
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateField('End Date', _endDate, (date) {
                      if (date != null) setState(() => _endDate = date);
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeField('Start Time', _startTime, (time) {
                      setState(() => _startTime = time);
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimeField('End Time', _endTime, (time) {
                      setState(() => _endTime = time);
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildLogoSelector(),
              const SizedBox(height: 48),
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Add Project',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.work_outline,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(item),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    DateTime date,
    Function(DateTime?) onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            onTap(picked);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(
                  IconsaxPlusLinear.calendar,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  "${date.day} ${_getMonthName(date.month)}, ${date.year}",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField(
    String label,
    TimeOfDay? time,
    Function(TimeOfDay?) onPicked,
  ) {
    final displayText = time != null
        ? time.format(context)
        : 'Optional';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: time ?? TimeOfDay.now(),
            );
            if (picked != null) {
              onPicked(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(
                  IconsaxPlusLinear.clock,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 12,
                      color: time != null ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (time != null)
                  GestureDetector(
                    onTap: () => onPicked(null),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoSelector() {
    return Row(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.shopping_basket_outlined,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Grocery logo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Change Logo',
              style: TextStyle(color: AppColors.primary, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
