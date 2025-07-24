import 'package:flutter/material.dart';

class CategoryModel {
  final String title;
  final IconData icon;
  final Color color;
  final int taskCount;

  CategoryModel({
    required this.title,
    required this.icon,
    required this.color,
    this.taskCount = 0,
  });
}
