import 'package:hive/hive.dart';

part 'task_model.g.dart'; // This will be generated automatically

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool done;

  @HiveField(2)
  DateTime? dueDate;

  @HiveField(3)
  String priority;

  @HiveField(4)
  String category;

  Task({
    required this.title,
    this.done = false,
    this.dueDate,
    this.priority = 'medium',
    this.category = 'personal',
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'done': done,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'category': category,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'] ?? '',
      done: json['done'] ?? false,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      priority: json['priority'] ?? 'medium',
      category: json['category'] ?? 'personal',
    );
  }
}
