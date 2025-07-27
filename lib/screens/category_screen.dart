import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:todo_app/data/sample_categories.dart';
import 'package:todo_app/screens/add_task_screen.dart';
import 'package:todo_app/screens/calendar_screen.dart';
import 'package:todo_app/screens/task_list_screen.dart';
import 'package:todo_app/widgets/category_card.dart';
import 'package:todo_app/screens/category_screen.dart';
import 'package:todo_app/models/category_model.dart';
import 'package:todo_app/models/calendar_model.dart';
import 'package:todo_app/screens/add_task_screen.dart';

class CategoryScreen extends StatelessWidget {
  final List<Calendar> tasks;
  final void Function(Calendar task) onTaskAdded;
  final void Function(String category) onCategoryTap;

  const CategoryScreen({
    super.key,
    required this.tasks,
    required this.onTaskAdded,
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
        onPressed: () async {
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );

          if (newTask != null && newTask is Calendar) {
            onTaskAdded(newTask);

            // Show success animation
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => Dialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/animations/success_check.json', // Use your actual file path
                        repeat: false,
                        height: 120,
                        width: 120,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Task Created!",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            );

            // Auto close the animation
            Future.delayed(const Duration(seconds: 2), () {
              if (context.mounted) Navigator.of(context).pop();
            });
          }
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
