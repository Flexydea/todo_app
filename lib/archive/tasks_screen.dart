// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../models/task_model.dart';

// class TasksScreen extends StatefulWidget {
//   const TasksScreen({super.key});

//   @override
//   State<TasksScreen> createState() => _TasksScreenState();
// }

// class _TasksScreenState extends State<TasksScreen> {
//   // Temporary mock list of tasks (replace with actual storage later)
//   List<Task> tasks = [
//     Task(title: 'Buy groceries', dueDate: DateTime.now(), done: false),
//     Task(
//       title: 'Read Flutter book',
//       dueDate: DateTime.now().add(Duration(days: 1)),
//       done: true,
//     ),
//     Task(
//       title: 'Go to gym',
//       dueDate: DateTime.now().add(Duration(days: 2)),
//       done: false,
//     ),
//   ];

//   // Helper method to format date
//   String formatDate(DateTime? date) {
//     if (date == null) return 'No date';
//     return DateFormat('dd MMM yyyy').format(date);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: tasks.length,
//         itemBuilder: (context, index) {
//           final task = tasks[index];

//           return Dismissible(
//             key: ValueKey(task.title + index.toString()),

//             // Swipe left to delete
//             direction: DismissDirection.endToStart,
//             background: Container(
//               alignment: Alignment.centerRight,
//               padding: const EdgeInsets.only(right: 20),
//               color: Colors.red,
//               child: const Icon(Icons.delete, color: Colors.white),
//             ),
//             onDismissed: (_) {
//               setState(() {
//                 tasks.removeAt(index);
//               });
//             },

//             child: Card(
//               elevation: 2,
//               margin: const EdgeInsets.symmetric(vertical: 8),
//               child: ListTile(
//                 leading: Icon(
//                   task.done ? Icons.check_circle : Icons.radio_button_unchecked,
//                   color: task.done ? Colors.green : Colors.grey,
//                 ),
//                 title: Text(
//                   task.title,
//                   style: TextStyle(
//                     decoration: task.done ? TextDecoration.lineThrough : null,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 subtitle: Text(
//                   'Due: ${formatDate(task.dueDate)}',
//                   style: const TextStyle(color: Colors.grey),
//                 ),
//                 onTap: () {
//                   // Toggle done status on tap
//                   setState(() {
//                     task.done = !task.done;
//                   });
//                 },
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
