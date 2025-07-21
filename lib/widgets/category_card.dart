import 'package:flutter/material.dart';
import 'package:todo_app/models/category_model.dart';
import 'package:todo_app/screens/task_list_screen.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to task list screen for this category
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TaskListScreen(category: category)),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(category.icon, size: 36, color: category.color),
              const SizedBox(height: 12),
              Text(
                category.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${category.taskCount} tasks'),
            ],
          ),
        ),
      ),
    );
  }
}
