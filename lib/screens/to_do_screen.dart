import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants.dart';
import '../models/task_model.dart';

class ToDoScreen extends StatelessWidget {
  const ToDoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('To Do Tasks')),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<TaskModel>('tasks').listenable(),
        builder: (context, Box<TaskModel> box, _) {
          final todoTasks = box.values.where((t) => !t.isCompleted).toList();

          if (todoTasks.isEmpty) {
            return Center(
              child: Text(
                'No pending tasks!',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : AppColors.greyText,
                  fontSize: 16,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: todoTasks.length,
            itemBuilder: (context, index) {
              final task = todoTasks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: CheckboxListTile(
                  value: task.isCompleted,
                  activeColor: AppColors.primary,
                  title: Text(
                    task.title,
                    style: TextStyle(
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