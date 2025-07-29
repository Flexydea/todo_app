import 'package:flutter/material.dart';
import 'package:todo_app/models/category_model.dart';
import 'package:todo_app/data/sample_categories.dart';

class CreateCategoryScreen extends StatefulWidget {
  const CreateCategoryScreen({super.key});

  @override
  State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  final TextEditingController _titleController = TextEditingController();
  IconData? _selectedIcon;
  Color _selectedColor = Colors.blue; // Default color

  final List<IconData> _availableIcons = [
    Icons.work,
    Icons.person,
    Icons.shopping_cart,
    Icons.warning,
    Icons.fitness_center,
    Icons.book,
    Icons.flight,
    Icons.school,
    Icons.movie,
  ];
  final List<Color> availableColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
  ];

  void _createCategory() {
    final title = _titleController.text.trim();
    if (title.isEmpty || _selectedIcon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title and choose an icon.')),
      );
      return;
    }

    // Add to sampleCategories
    final newCategory = CategoryModel(
      title: title,
      icon: _selectedIcon!,
      color: _selectedColor,
    );

    // sampleCategories.add(newCategory); // Add to list

    Navigator.pop(context, newCategory); // Go back to CategoryScreen
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Category'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableIcons.map((iconData) {
                  final isSelected = _selectedIcon == iconData;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = iconData),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: isSelected
                          ? theme.primaryColor
                          : Colors.grey[200],
                      child: Icon(
                        iconData,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            // Icon picker
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Choose Color",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: availableColors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == color
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(radius: 16, backgroundColor: color),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            // Save button
            SizedBox(
              width: double.infinity, // Makes button full-width
              child: ElevatedButton.icon(
                onPressed: _createCategory,
                // icon: const Icon(Icons.save, color: Colors.black),
                label: const Text(
                  'Save Category',
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Green background
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
