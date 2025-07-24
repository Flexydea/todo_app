import 'package:flutter/material.dart';
import 'package:todo_app/models/category_model.dart';
import 'package:todo_app/screens/task_list_screen.dart'; // Make sure to import this

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final int totalTasks;
  final int completedTasks;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.totalTasks,
    required this.completedTasks,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(category.icon, size: 40, color: category.color),
              const SizedBox(height: 10),
              Text(
                category.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: totalTasks == 0 ? 0 : completedTasks / totalTasks,
              ),
              Text(
                '$completedTasks of $totalTasks  completed',
                style: const TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
