import 'package:flutter/material.dart';
import 'package:todo_app/models/category_model.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final int totalTasks;
  final int completedTasks;
  final VoidCallback onTap;
  final VoidCallback? onLongPress; // optional

  const CategoryCard({
    super.key,
    required this.category,
    required this.totalTasks,
    required this.completedTasks,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress, // Delegate long press to parent
      child: Card(
        color: theme.cardColor,
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
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: totalTasks == 0 ? 0 : completedTasks / totalTasks,
                backgroundColor: theme.dividerColor.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(category.color),
              ),
              const SizedBox(height: 6),
              Text(
                '$completedTasks of $totalTasks completed',
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
