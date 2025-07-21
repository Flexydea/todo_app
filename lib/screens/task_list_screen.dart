import 'package:flutter/material.dart';
import 'package:todo_app/models/category_model.dart';

class TaskListScreen extends StatelessWidget {
  final CategoryModel category;

  const TaskListScreen({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${category.title} Tasks'),
        backgroundColor: category.color,
      ),
      body: Center(
        child: Text(
          'Display tasks for ${category.title} here.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
