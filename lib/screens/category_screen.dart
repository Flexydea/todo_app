import 'package:flutter/material.dart';
import 'package:todo_app/data/sample_categories.dart';
import 'package:todo_app/widgets/category_card.dart';
import 'package:todo_app/screens/category_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: sampleCategories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            return CategoryCard(category: sampleCategories[index]);
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
