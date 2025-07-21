import 'package:flutter/material.dart';
import 'package:todo_app/models/category_model.dart';

final List<CategoryModel> sampleCategories = [
  CategoryModel(
    title: 'Work',
    icon: Icons.work,
    color: Colors.blue,
    taskCount: 5,
  ),
  CategoryModel(
    title: 'Personal',
    icon: Icons.person,
    color: Colors.orange,
    taskCount: 3,
  ),
  CategoryModel(
    title: 'Shopping',
    icon: Icons.shopping_cart,
    color: Colors.green,
    taskCount: 2,
  ),
  CategoryModel(
    title: 'Urgent',
    icon: Icons.warning,
    color: Colors.red,
    taskCount: 1,
  ),
];
