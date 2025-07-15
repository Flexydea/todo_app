// File: lib/models/task_model.dart

class Task {
  String title;
  bool done;
  DateTime? dueDate;
  String priority;
  String category;

  // Constructor with default values for category and priority
  Task({
    required this.title,
    this.done = false,
    this.dueDate,
    this.priority = 'medium',
    this.category = 'personal',
  });

  // Convert a Task object to a Map (for saving to storage)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'done': done,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'category': category,
    };
  }

  // Factory constructor to create a Task from a Map (when loading)
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      done: json['done'],
      dueDate: json['dueDate'] != null && json['dueDate'] != ''
          ? DateTime.tryParse(json['dueDate'])
          : null,
      priority: json['priority'] ?? 'medium',
      category: json['category'] ?? 'personal',
    );
  }
}
