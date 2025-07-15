// ignore_for_file: unused_field, unused_local_variable, no_leading_underscores_for_local_identifiers, unused_element

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class ToDoScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  // String _selectedCategory = 'personal'; // default category

  ToDoScreen({required this.isDarkMode, required this.onToggleTheme});

  @override
  _ToDoScreenState createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen>
    with SingleTickerProviderStateMixin {
  bool _showCompleted = true;
  bool _showTodayOnly = false;
  bool _isDarkMode = false;
  String _selectedPriority = 'medium'; // default
  String _selectedCategory = 'personal';
  String _filterCategory = 'All';
  List<String> _categories = ['work', 'personal', 'other'];
  String _selectedFilterCategory = 'all';
  final TextEditingController _controller = TextEditingController();

  //tasks is now a list of Task objects, not a list of maps.///
  List<Task> _tasks = [];

  late TabController _tabController;

  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    _loadThemePreference();
    _loadTasks(); // load saved tasks
  }

  //dark theme loading preference
  void _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  // ✅ Load tasks from device storage
  void _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString('tasks');

    if (tasksString != null) {
      final List<dynamic> taskJson = jsonDecode(tasksString);
      setState(() {
        _tasks = taskJson.map((json) => Task.fromJson(json)).toList();
      });
    }
  }

  // ✅ Save tasks to device storage

  // to edit a list
  void _editTask(Task task) {
    final TextEditingController editController = TextEditingController(
      text: task.title,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: TextField(
            controller: editController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Update task',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(fontSize: 20)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save', style: TextStyle(fontSize: 20)),
              onPressed: () {
                setState(() {
                  task.title = editController.text;
                  task = task;
                });
                _saveTasks();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert each Task object to a Map using .toJson()
    final taskListJson = _tasks.map((task) => task.toJson()).toList();

    // Encode the list of maps as a JSON string
    await prefs.setString('tasks', json.encode(taskListJson));
  }

  @override
  Widget build(BuildContext context) {
    //arrange the list according to dates
    _tasks.sort((a, b) {
      final aDate = a.dueDate;
      final bDate = b.dueDate;

      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1; // push a down
      if (bDate == null) return -1; // push b down

      return aDate.compareTo(bDate);
    });

    List<Task> pendingTasks = _tasks.where((task) {
      if (task.done) return false;

      if (_showTodayOnly && task.dueDate != null) {
        final today = DateTime.now();
        return task.dueDate!.year == today.year &&
            task.dueDate!.month == today.month &&
            task.dueDate!.day == today.day;
      }

      return true;
    }).toList();

    List<Task> completedTasks = _tasks.where((task) => task.done).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text("Godwin's To-Do App"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildAddTaskTab(), _buildTaskListTab()],
      ),
      bottomNavigationBar: Material(
        color: const Color.fromARGB(255, 13, 36, 21),
        child: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.add), text: 'Add Task'),
            Tab(icon: Icon(Icons.list), text: 'My Tasks'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
    );
    // 🧱 Builds a single task tile with swipe actions

    Widget _buildTaskTile(Task task) {
      // Function to determine color based on priority

      Color getCategoryColor(String category) {
        switch (category.toLowerCase()) {
          case 'work':
            return Colors.blue;
          case 'personal':
            return Colors.purple;
          case 'shopping':
            return Colors.teal;
          case 'other':
            return Colors.grey;
          default:
            return Colors.black;
        }
      }

      // Determine the color of the priority label based on its value
      Color getPriorityColor(String priority) {
        switch (priority) {
          case 'high':
            return Colors.red;
          case 'medium':
            return Colors.orange;
          case 'low':
            return Colors.green;
          default:
            return Colors.grey;
        }
      }

      // Get this task's priority
      final priority = task.priority ?? 'none';
      return Dismissible(
        key: Key(task.title + task.toString()), // Unique key
        background: Container(
          color: Colors.green,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 20),
          child: Icon(Icons.check, color: Colors.white),
        ),
        secondaryBackground: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20),
          child: Icon(Icons.delete, color: Colors.white),
        ),

        // Handle swipe confirmation
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            // Confirm before deleting
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('Delete Task'),
                content: Text('Are you sure you want to delete this task?'),
                actions: [
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () => Navigator.of(ctx).pop(false),
                  ),
                  TextButton(
                    child: Text('Delete'),
                    onPressed: () => Navigator.of(ctx).pop(true),
                  ),
                ],
              ),
            );
            return confirm ?? false;
          } else {
            // Mark as complete on swipe right
            setState(() {
              task.done = !task.done;
              _saveTasks();
            });
            return false; // Don't dismiss the tile visually
          }
        },

        // Actually remove task if deleted
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            setState(() {
              _tasks.remove(task); // ✅ Correct way to remove by object
            });
            _saveTasks();
          }
        },

        child: ListTile(
          title: GestureDetector(
            onTap: () => _editTask(task),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    decoration: task.done
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                if (task.dueDate != null && task.dueDate != '')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date: ${task.dueDate!.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      Text(
                        'Time: ${TimeOfDay.fromDateTime(task.dueDate!.toLocal()).format(context)}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                Text(
                  'Priority: ${(task.priority ?? 'none').toUpperCase()}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: getPriorityColor(task.priority),
                  ),
                ),
                Text(
                  'Category: ${task.category?.toUpperCase() ?? 'NONE'}',
                  style: TextStyle(fontSize: 13, color: Colors.blueGrey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    //collapse
    // Default: Show all tasks line 86
    @override
    void dispose() {
      _tabController.dispose();
      super.dispose();
    }
  }

  ////////// TAB section ////////////

  // Tab for adding new tasks
  Widget _buildAddTaskTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🔹 Task input
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Enter a task today',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),

          // 🔹 Category dropdown
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Select Category',
              border: OutlineInputBorder(),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
            },
          ),
          const SizedBox(height: 10),

          // 🔹 Priority dropdown
          DropdownButtonFormField<String>(
            value: _selectedPriority,
            decoration: const InputDecoration(
              labelText: 'Select Priority',
              border: OutlineInputBorder(),
            ),
            items: ['low', 'medium', 'high'].map((priority) {
              return DropdownMenuItem(
                value: priority,
                child: Text(priority.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPriority = value!;
              });
            },
          ),
          const SizedBox(height: 10),

          // 🔹 Add task button
          ElevatedButton(
            onPressed: _handleAddTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text('Add Task', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 10),

          // 🔹 Clear all tasks button
          ElevatedButton(
            onPressed: _tasks.isEmpty
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Clear All Tasks'),
                          content: const Text(
                            'Do you want to delete ALL tasks?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _tasks.clear();
                                });
                                _saveTasks();
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'Clear All',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text(
              'Clear All Tasks',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  /////// TAB MY LIST /////////////
  // Tab for displaying tasks (pending + completed)
  Widget _buildTaskListTab() {
    // Separate tasks into pending and completed

    final pendingTasks = _tasks.where((task) {
      if (task.done) return false;

      final matchesSearch = task.title.toLowerCase().contains(_searchQuery);
      if (_searchQuery.isNotEmpty && !matchesSearch) return false;

      if (_showTodayOnly && task.dueDate != null) {
        final today = DateTime.now();
        return task.dueDate!.year == today.year &&
            task.dueDate!.month == today.month &&
            task.dueDate!.day == today.day;
      }

      return true;
    }).toList();

    final completedTasks = _tasks.where((task) {
      if (!task.done) return false;

      final matchesSearch = task.title.toLowerCase().contains(_searchQuery);
      return _searchQuery.isEmpty || matchesSearch;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          /// 🔹 FILTER CONTROLS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Toggle Today Only
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showTodayOnly = !_showTodayOnly;
                  });
                },
                icon: Icon(
                  _showTodayOnly ? Icons.today : Icons.view_agenda,
                  color: Colors.blue,
                ),
                label: Text(
                  _showTodayOnly ? 'Show All' : 'Today Only',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),

              // Toggle Completed
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showCompleted = !_showCompleted;
                  });
                },
                icon: Icon(
                  _showCompleted ? Icons.visibility_off : Icons.visibility,
                  color: Colors.blue,
                ),
                label: Text(
                  _showCompleted ? 'Hide Completed' : 'Show Completed',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),

          // Category filter
          DropdownButtonFormField<String>(
            value: _selectedFilterCategory,
            decoration: const InputDecoration(
              labelText: 'Filter by Category',
              border: OutlineInputBorder(),
            ),
            items: ['all', ..._categories].map((cat) {
              return DropdownMenuItem(
                value: cat,
                child: Text(cat.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedFilterCategory = value!;
              });
            },
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value
                      .toLowerCase(); // store lowercase search term
                });
              },
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear(); // clear text
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          /// 🔹 TASK DISPLAY
          Expanded(
            child: Builder(
              builder: (context) {
                final hasNoTasks =
                    pendingTasks.isEmpty &&
                    (!_showCompleted || completedTasks.isEmpty);

                if (hasNoTasks) {
                  return const Center(
                    child: Text(
                      'No tasks in this category.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView(
                  children: [
                    if (pendingTasks.isNotEmpty) ...[
                      const Text(
                        'Pending Tasks',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...pendingTasks.asMap().entries.map((entry) {
                        final index = _tasks.indexOf(entry.value);
                        final task = entry.value;
                        return _buildTaskTile(task, index);
                      }),
                    ],
                    if (_showCompleted && completedTasks.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'Completed Tasks',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...completedTasks.asMap().entries.map((entry) {
                        final index = _tasks.indexOf(entry.value);
                        final task = entry.value; // ✅ Define the task here
                        return _buildTaskTile(task, index); // ✅ Now pass both
                      }),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(Task task, int index) {
    Color getPriorityColor(String priority) {
      switch (priority) {
        case 'high':
          return Colors.red;
        case 'medium':
          return Colors.orange;
        case 'low':
          return Colors.green;
        default:
          return Colors.grey;
      }
    }

    return Dismissible(
      key: Key(task.title + task.dueDate.toString()),
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20),
        child: Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Delete Task'),
              content: Text('Are you sure you want to delete this task?'),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(ctx).pop(false),
                ),
                TextButton(
                  child: Text('Delete'),
                  onPressed: () => Navigator.of(ctx).pop(true),
                ),
              ],
            ),
          );
          return confirm ?? false;
        } else {
          setState(() {
            task.done = !task.done;
            _saveTasks();
          });
          return false;
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          setState(() {
            _tasks.removeAt(index); // ✅ Remove by index
          });
          _saveTasks();
        }
      },
      child: ListTile(
        title: GestureDetector(
          onTap: () => _editTask(task),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: TextStyle(
                  fontSize: 16,
                  decoration: task.done
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              if (task.dueDate != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date: ${task.dueDate!.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    Text(
                      'Time: ${TimeOfDay.fromDateTime(task.dueDate!.toLocal()).format(context)}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              Text(
                'Priority: ${task.priority.toUpperCase()}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: getPriorityColor(task.priority),
                ),
              ),
              Text(
                'Category: ${task.category.toUpperCase()}',
                style: TextStyle(fontSize: 13, color: Colors.blueGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAddTask() async {
    if (_controller.text.isEmpty) return;

    // Step 1: Ask for the due date
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (selectedDate == null) return;

    // Step 2: Ask for the time
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime == null) return;

    // Step 3: Combine both into a single DateTime
    final combinedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // Step 4: Create a Task object instead of a Map
    final newTask = Task(
      title: _controller.text,
      dueDate: combinedDateTime,
      priority: _selectedPriority,
      category: _selectedCategory,
    );

    // ✅ Add new task as a Task object (not a map)
    setState(() {
      _tasks.add(
        Task(
          title: _controller.text,
          done: false,
          dueDate: combinedDateTime,
          priority: _selectedPriority,
          category: _selectedCategory,
        ),
      );
      _controller.clear(); // Clear input field
    });

    _saveTasks(); // Save to storage
  }
}
