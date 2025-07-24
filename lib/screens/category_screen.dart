import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/data/sample_categories.dart';
import 'package:todo_app/screens/task_list_screen.dart';
import 'package:todo_app/widgets/category_card.dart';
import 'package:todo_app/screens/category_screen.dart';
import 'package:todo_app/models/category_model.dart';

class CategoryScreen extends StatelessWidget {
  CategoryScreen({super.key});
  // final List<CategoryModel> categories = [
  //   CategoryModel(title: 'Work', icon: Icons.work, color: Colors.blue),
  //   CategoryModel(title: 'Personal', icon: Icons.person, color: Colors.orange),
  //   CategoryModel(
  //     title: 'Shopping',
  //     icon: Icons.shopping_cart,
  //     color: Colors.green,
  //   ),
  //   CategoryModel(title: 'Urgent', icon: Icons.warning, color: Colors.red),
  // ];

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
              completedTasks: 0, // or set a dummy number if needed
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TaskListScreen(category: category),
                  ),
                );
              },
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
