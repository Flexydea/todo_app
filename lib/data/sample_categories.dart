import 'package:flutter/material.dart';
import 'package:todo_app/models/category_model.dart';

final List<Category> sampleCategories = [
  Category(title: 'Work', icon: Icons.work, color: Colors.blue, taskCount: 5),
  Category(
    title: 'Personal',
    icon: Icons.person,
    color: Colors.orange,
    taskCount: 3,
  ),
  Category(
    title: 'Shopping',
    icon: Icons.shopping_cart,
    color: Colors.green,
    taskCount: 2,
  ),
  Category(
    title: 'Urgent',
    icon: Icons.warning,
    color: Colors.red,
    taskCount: 1,
  ),
];
