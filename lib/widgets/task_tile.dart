// File: lib/widgets/task_tile.dart
import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskTile extends StatelessWidget {
  final Task task;

  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        task.done ? Icons.check_circle : Icons.radio_button_unchecked,
        color: task.done ? Colors.green : Colors.grey,
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.done ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(
        '${task.category} • ${task.priority.toUpperCase()}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: task.dueDate != null
          ? Text(
              '${task.dueDate!.hour.toString().padLeft(2, '0')}:${task.dueDate!.minute.toString().padLeft(2, '0')}',
            )
          : null,
    );
  }
}
