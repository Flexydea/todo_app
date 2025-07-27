import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/data/sample_categories.dart';
import 'package:todo_app/screens/calendar_screen.dart';
import 'package:todo_app/screens/task_list_screen.dart';
import 'package:todo_app/widgets/category_card.dart';
import 'package:todo_app/screens/category_screen.dart';
import 'package:todo_app/models/category_model.dart';

class CategoryScreen extends StatelessWidget {
  final Function(String category) onCategoryTap;

  const CategoryScreen({super.key, required this.onCategoryTap});
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

            return CategoryCard(
              category: category,
              totalTasks: category.taskCount,
              completedTasks: 0,
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
