import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants.dart';
import '../models/task_model.dart';

class CompletedScreen extends StatelessWidget {
  const CompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Completed Tasks')),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<TaskModel>('tasks').listenable(),
        builder: (context, Box<TaskModel> box, _) {
          final completedTasks = box.values.where((t) => t.isCompleted).toList();

          if (completedTasks.isEmpty) {
            return Center(
              child: Text(
                'No completed tasks yet.',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : AppColors.greyText,
                  fontSize: 16,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: completedTasks.length,
            itemBuilder: (context, index) {
              final task = completedTasks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: CheckboxListTile(
                  value: task.isCompleted,
                  activeColor: AppColors.primary,
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[400] : AppColors.greyText, // لون خافت للمهام المكتملة
                    ),
                  ),
                  subtitle: task.description.isNotEmpty
                      ? Text(
                          task.description,
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: isDark ? Colors.grey[600] : Colors.grey,
                          ),
                        )
                      : null,
                  onChanged: (val) {
                    task.isCompleted = val ?? false;
                    task.save();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}