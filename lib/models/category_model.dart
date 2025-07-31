import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/adapters/icon_data_adapter.dart';
import 'package:todo_app/adapters/color_adapter.dart';

part 'category_model.g.dart';

@HiveType(typeId: 33)
class Category extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final IconData icon;

  @HiveField(2)
  final Color color;

  @HiveField(3)
  final int taskCount;

  Category({
    required this.title,
    required this.icon,
    required this.color,
    this.taskCount = 0,
  });
}
