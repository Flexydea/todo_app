import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/category_model.dart';
import 'package:todo_app/providers/selected_category_provider.dart';
import 'package:todo_app/screens/add_task_screen.dart';
import 'package:todo_app/screens/create_category_screen.dart';
import 'package:todo_app/widgets/category_card.dart';
import 'package:todo_app/models/category_model.dart';
import 'package:todo_app/models/calendar_model.dart';

class CategoryScreen extends StatefulWidget {
  // final List<Calendar> tasks;
  // final void Function(Calendar task) onTaskAdded;
  final void Function(String category) onCategoryTap;

  // const CategoryScreen({
  //   super.key,
  //   required this.tasks,
  //   required this.onTaskAdded,
  //   required this.onCategoryTap,
  // });
  const CategoryScreen({super.key, required this.onCategoryTap});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Box<Category> _categoryBox;

  @override
  void initState() {
    super.initState();
    _categoryBox = Hive.box<Category>('categoryBox');
  }

  void _confirmDelete(BuildContext context, String title) {
    final isDefault = [
      'Work',
      'Personal',
      'Shopping',
      'Urgent',
    ].contains(title);
    if (isDefault) return;

    final box = Hive.box<Category>('categoryBox');

    // 🔁 Find the key directly instead of relying on index
    final keyToDelete = box.keys.firstWhere(
      (key) => box.get(key)?.title == title,
      orElse: () => null,
    );

    if (keyToDelete == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Category"),
        content: Text("Are you sure you want to delete '$title'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              box.delete(keyToDelete); // ✅ Use key here
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ValueListenableBuilder<Box<Calendar>>(
          valueListenable: Hive.box<Calendar>('calendarBox').listenable(),
          builder: (context, calendarBox, _) {
            return ValueListenableBuilder<Box<Category>>(
              valueListenable: Hive.box<Category>('categoryBox').listenable(),
              builder: (context, categoryBox, _) {
                final categories = categoryBox.values.toList();

                return GridView.builder(
                  itemCount: categories.length + 1,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    if (index == categories.length) {
                      return GestureDetector(
                        onTap: () async {
                          final newCategory = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateCategoryScreen(),
                            ),
                          );

                          if (newCategory != null && newCategory is Category) {
                            final exists = categoryBox.values.any(
                              (c) =>
                                  c.title.trim().toLowerCase() ==
                                  newCategory.title.trim().toLowerCase(),
                            );

                            if (exists) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Category already exists'),
                                ),
                              );
                            } else {
                              categoryBox.add(newCategory);
                            }
                          }
                        },
                        child: Card(
                          color: theme.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, size: 40, color: Colors.green),
                                const SizedBox(height: 10),
                                Text(
                                  "Create Category",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final category = categories[index];

                    final categoryTasks = calendarBox.values
                        .where((task) => task.category == category.title)
                        .toList();

                    final totalTasks = categoryTasks.length;
                    final completedTasks = categoryTasks
                        .where((task) => task.done)
                        .length;

                    return CategoryCard(
                      category: category,
                      totalTasks: totalTasks,
                      completedTasks: completedTasks,
                      onTap: () {
                        Provider.of<SelectedCategoryProvider>(
                          context,
                          listen: false,
                        ).setCategory(category.title);

                        widget.onCategoryTap(category.title);
                      },
                      onLongPress: () =>
                          _confirmDelete(context, category.title),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );

          if (newTask != null && newTask is Calendar) {
            // Task is already saved to Hive in AddTaskScreen
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => Dialog(
                backgroundColor: theme.cardColor,
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
                        'assets/animations/success_check.json',
                        repeat: false,
                        height: 120,
                        width: 120,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Task Created!",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

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
