// // ignore_for_file: unused_field, unused_local_variable, no_leading_underscores_for_local_identifiers, unused_element

// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import '../models/task_model.dart';
// import 'package:lottie/lottie.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ToDoScreen extends StatefulWidget {
//   final bool isDarkMode;
//   final VoidCallback onToggleTheme;

//   const ToDoScreen({
//     Key? key,
//     required this.isDarkMode,
//     required this.onToggleTheme,
//   }) : super(key: key);

//   @override
//   _ToDoScreenState createState() => _ToDoScreenState();
// }

// class _ToDoScreenState extends State<ToDoScreen>
//     with SingleTickerProviderStateMixin {
//   bool _showCompleted = true;
//   bool _showTodayOnly = false;
//   bool _isShowingDeleteAnimation = false;
//   bool _isDarkMode = false;
//   String _selectedPriority = 'medium';
//   String _selectedCategory = 'personal';
//   String _filterCategory = 'All';
//   List<String> _categories = ['work', 'personal', 'other'];
//   String _selectedFilterCategory = 'all';
//   final TextEditingController _controller = TextEditingController();
//   final TextEditingController _titleController = TextEditingController();
//   List<Task> _tasks = [];
//   late TabController _tabController;
//   TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _loadThemePreference();
//     _loadTasksFromHive();
//   }

//   void _loadThemePreference() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _isDarkMode = prefs.getBool('darkMode') ?? false;
//     });
//   }

//   Future<void> _saveTasksToHive() async {
//     final box = Hive.box<Task>('tasksBox');
//     await box.clear();
//     for (var task in _tasks) {
//       await box.add(task);
//     }
//   }

//   void _loadTasksFromHive() async {
//     final box = Hive.box<Task>('tasksBox');
//     setState(() {
//       _tasks = box.values.toList();
//     });
//   }

//   void _saveTasks() {
//     _saveTasksToHive();
//   }

//   void _editTask(Task task) {
//     TextEditingController titleController = TextEditingController(
//       text: task.title,
//     );
//     String selectedCategory = task.category;
//     String selectedPriority = task.priority;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) {
//         return Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom,
//             top: 20,
//             left: 16,
//             right: 16,
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Text(
//                     "Edit Task",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 SizedBox(height: 12),
//                 TextField(
//                   controller: titleController,
//                   decoration: InputDecoration(labelText: 'Task Title'),
//                 ),
//                 SizedBox(height: 12),
//                 DropdownButtonFormField<String>(
//                   value: _selectedFilterCategory,
//                   decoration: const InputDecoration(
//                     labelText: 'Filter by Category',
//                     border: OutlineInputBorder(),
//                   ),
//                   items: ['all', ..._categories].map((cat) {
//                     return DropdownMenuItem(
//                       value: cat,
//                       child: Text(cat.toUpperCase()),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedFilterCategory = value!;
//                     });
//                   },
//                 ),
//                 SizedBox(height: 12),
//                 DropdownButtonFormField<String>(
//                   value: selectedPriority,
//                   decoration: InputDecoration(labelText: 'Priority'),
//                   items: ['low', 'medium', 'high'].map((priority) {
//                     return DropdownMenuItem(
//                       value: priority,
//                       child: Text(priority.toUpperCase()),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     selectedPriority = value!;
//                   },
//                 ),
//                 SizedBox(height: 16),
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         task.title = titleController.text;
//                         task.category = selectedCategory;
//                         task.priority = selectedPriority;
//                       });
//                       _saveTasks();
//                       Navigator.of(context).pop();
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                     ),
//                     child: Text(
//                       'Save',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 16),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // Everything else (animations, UI, tabs, task form, etc.) stays the same
//   // but ensure all calls to `_saveTasks()` are retained, and internally they call Hive only.

//   // No need to paste the rest again here unless further cleanups or changes are required.
// }
