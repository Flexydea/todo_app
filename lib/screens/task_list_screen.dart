import 'package:flutter/material.dart';
import 'package:todo_app/models/task_model.dart';
import '../widgets/task_tile.dart';
import 'package:todo_app/models/category_model.dart';

class TaskListScreen extends StatefulWidget {
  final CategoryModel category;

  const TaskListScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // Mock task data
  List<Task> allTasks = [
    Task(
      title: 'Buy groceries',
      dueDate: DateTime(2025, 7, 23),
      category: 'Urgent',
    ),
    Task(
      title: 'Read Flutter book',
      dueDate: DateTime(2025, 7, 24),
      done: true,
      category: 'Urgent',
    ),
    Task(
      title: 'Go to gym',
      dueDate: DateTime(2025, 7, 25),
      category: 'Urgent',
    ),
    Task(
      title: 'Call mom',
      dueDate: DateTime(2025, 7, 23),
      category: 'Personal',
    ),
  ];

  String _filterValue = 'all';

  // Filtered tasks based on selected category and filter (all/completed/uncompleted)
  List<Task> get filteredTasks {
    List<Task> tasksByCategory = allTasks
        .where(
          (task) =>
              task.category.toLowerCase() ==
              widget.category.title.toLowerCase(),
        )
        .toList();

    if (_filterValue == 'completed') {
      return tasksByCategory.where((task) => task.done).toList();
    } else if (_filterValue == 'uncompleted') {
      return tasksByCategory.where((task) => !task.done).toList();
    }

    return tasksByCategory;
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = widget.category.color;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category.title} Tasks'),
        backgroundColor: categoryColor,
      ),
      body: ListView.builder(
        itemCount: filteredTasks.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final task = filteredTasks[index];

          return Dismissible(
            key: Key(task.title + task.dueDate.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              setState(() {
                allTasks.remove(task);
              });
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("${task.title} deleted")));
            },

            // Wrap each task in a Card
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: IconButton(
                    icon: Icon(
                      task.done
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: task.done ? Colors.green : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        task.done = !task.done;
                      });
                    },
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: task.done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(
                    'Due: ${_formatDate(task.dueDate)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper to format the date like "23 Jul 2025"
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')} '
        '${_monthAbbr(date.month)} '
        '${date.year}';
  }

  // Helper to get month abbreviation from number
  String _monthAbbr(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
