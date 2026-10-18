import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants.dart';
import '../models/task_model.dart';
import 'new_task_screen.dart';

class HomeScreen extends StatelessWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final settingsBox = Hive.box('settings');
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: Hive.box<TaskModel>('tasks').listenable(),
          builder: (context, Box<TaskModel> box, _) {
            final tasks = box.values.toList();
            final completedCount = tasks.where((t) => t.isCompleted).length;
            final totalCount = tasks.length;
            final double percent = totalCount == 0 ? 0 : (completedCount / totalCount);

            final highPriorityTasks = tasks.where((t) => t.isHighPriority && !t.isCompleted).toList();
            
            // جلب الاقتباس المتغير
            String quote = settingsBox.get(
              'motivationQuote',
              defaultValue: 'One task at a time. One step closer.',
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header (اسم المستخدم والترحيب متوافق مع Dark Mode)
                  Text(
                    'Good Evening, $userName',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quote,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : AppColors.greyText,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Achieved Tasks Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Yuhuu, Your work Is almost done!',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Achieved Tasks', style: TextStyle(color: Colors.white70)),
                            Text(
                              '$completedCount Out of $totalCount Done ${(percent * 100).toInt()}%',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: percent,
                          backgroundColor: Colors.white30,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // High Priority Tasks
                  if (highPriorityTasks.isNotEmpty) ...[
                    Text(
                      'High Priority Tasks',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...highPriorityTasks.map((task) => _buildTaskTile(context, task, isDark)),
                    const SizedBox(height: 20),
                  ],

                  // My Tasks Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Tasks',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NewTaskScreen()),
                          );
                        },
                        icon: const Icon(Icons.add, size: 18, color: Colors.white),
                        label: const Text('Add New Task', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (tasks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: Text(
                          'No tasks available.',
                          style: TextStyle(color: isDark ? Colors.grey[400] : AppColors.greyText),
                        ),
                      ),
                    )
                  else
                    ...tasks.map((task) => _buildTaskTile(context, task, isDark)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTaskTile(BuildContext context, TaskModel task, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          activeColor: AppColors.primary,
          onChanged: (val) {
            task.isCompleted = val ?? false;
            task.save();
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
        subtitle: task.description.isNotEmpty
            ? Text(
                task.description,
                style: TextStyle(color: isDark ? Colors.grey[400] : AppColors.greyText),
              )
            : null,
      ),
    );
  }
}