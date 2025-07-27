import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/data/sample_categories.dart';
import 'package:todo_app/screens/calendar_screen.dart';
import 'package:todo_app/screens/task_list_screen.dart';
import 'package:todo_app/widgets/category_card.dart';
import 'package:todo_app/screens/category_screen.dart';
import 'package:todo_app/models/category_model.dart';
import 'package:todo_app/models/calendar_model.dart';

class CategoryScreen extends StatelessWidget {
  final List<Calendar> tasks;
  final Function(String) onCategoryTap;

  const CategoryScreen({
    super.key,
    required this.tasks,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: sampleCategories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final category = sampleCategories[index];

            // Filter tasks for this category
            final tasksForCategory = tasks
                .where((task) => task.category == category.title)
                .toList();
            final totalTasks = tasksForCategory.length;
            final completedTasks = tasksForCategory
                .where((task) => task.done)
                .length;

            return CategoryCard(
              category: category,
              totalTasks: totalTasks,
              completedTasks: completedTasks,
              onTap: () => onCategoryTap(category.title),
            );
          },
        ),
      ),

      // Floating Create Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Handle create list action
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
        // label: const Text('Create'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
