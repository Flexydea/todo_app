// import 'package:flutter/material.dart';
// import 'package:todo_app/models/task_model.dart';
// import 'package:todo_app/constants/categories.dart';

// class EditTaskScreen extends StatefulWidget {
//   final Task task;

//   const EditTaskScreen({Key? key, required this.task}) : super(key: key);

//   @override
//   State<EditTaskScreen> createState() => _EditTaskScreenState();
// }

// class _EditTaskScreenState extends State<EditTaskScreen> {
//   late TextEditingController _titleController;
//   late TimeOfDay _selectedTime;
//   late String _selectedCategory;
//   late DateTime _selectedDate;
//   bool _isDone = false;

//   final List<String> _categories = ['work', 'personal', 'shopping', 'urgent'];
//   @override
//   void initState() {
//     super.initState();
//     _titleController = TextEditingController(text: widget.task.title);
//     _selectedTime = TimeOfDay.fromDateTime(
//       widget.task.dueDate ?? DateTime.now(),
//     );
//     _selectedTime = TimeOfDay.fromDateTime(
//       widget.task.dueDate ?? DateTime.now(),
//     );
//     _isDone = widget.task.done;
//     _selectedCategory = widget.task.category.toLowerCase();
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     super.dispose();
//   }

//   void _pickTime() async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: _selectedTime,
//     );
//     if (picked != null) {
//       setState(() {
//         _selectedTime = picked;
//         // Update _selectedDate time part
//         _selectedDate = DateTime(
//           _selectedDate.year,
//           _selectedDate.month,
//           _selectedDate.day,
//           _selectedTime.hour,
//           _selectedTime.minute,
//         );
//       });
//     }
//   }

//   void _saveTask() {
//     final updatedDateTime = DateTime(
//       _selectedDate.year,
//       _selectedDate.month,
//       _selectedDate.day,
//       _selectedTime.hour,
//       _selectedTime.minute,
//     );

//     final updatedTask = Task(
//       id: widget.task.id,
//       title: _titleController.text.trim(),
//       done: _isDone,
//       dueDate: updatedDateTime,
//       time: _selectedTime,
//       category: _selectedCategory.toLowerCase(),
//       priority: 'medium',
//     );

//     Navigator.pop(context, updatedTask);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Edit Task')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextField(
//               controller: _titleController,
//               decoration: const InputDecoration(
//                 labelText: 'Task Title',
//                 border: OutlineInputBorder(),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.green),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Text('Time: ${_selectedTime.format(context)}'),
//                 const SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: _pickTime,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     foregroundColor: Colors.white,
//                   ),
//                   child: const Text('Change'),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             DropdownButtonFormField<String>(
//               value: _selectedCategory,
//               decoration: const InputDecoration(
//                 labelText: 'Category',
//                 border: OutlineInputBorder(),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.green),
//                 ),
//               ),
//               items: _categories.map((category) {
//                 return DropdownMenuItem(
//                   value: category,
//                   child: Text(
//                     '${category[0].toUpperCase()}${category.substring(1)}', // Capitalized for display
//                   ),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _selectedCategory = value!;
//                 });
//               },
//             ),
//             const SizedBox(height: 4),
//             Center(
//               child: ElevatedButton(
//                 onPressed: _saveTask,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 30,
//                     vertical: 12,
//                   ),
//                 ),
//                 child: const Text(
//                   'Save Changes',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
