// ignore_for_file: unused_field, unused_local_variable, no_leading_underscores_for_local_identifiers, unused_element

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';
import 'package:lottie/lottie.dart';

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
  bool _isShowingDeleteAnimation = false;
  bool _isDarkMode = false;
  String _selectedPriority = 'medium'; // default
  String _selectedCategory = 'personal';
  String _filterCategory = 'All';
  List<String> _categories = ['work', 'personal', 'other'];
  String _selectedFilterCategory = 'all';
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

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

  void _showSuccessAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: const Color.fromARGB(255, 42, 104, 34),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/success_check.json',
                repeat: false,
                onLoaded: (composition) {
                  Future.delayed(composition.duration, () {
                    if (Navigator.canPop(context)) {
                      Navigator.of(
                        context,
                      ).pop(); // Only closes the dialog once
                    }
                  });
                },
              ),
              SizedBox(height: 10),
              Text("Task added!", style: TextStyle(color: Colors.white)),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 200,
          width: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/delete.json',
                repeat: false,
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 10),
              const Text(
                'Task deleted!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );

    // Auto close after animation plays
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  void _showClearAllDeleteAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: SizedBox(
          height: 200,
          width: 200,
          child: Lottie.asset(
            'assets/animations/delete.json',
            repeat: false,
            onLoaded: (composition) {
              Future.delayed(composition.duration, () {
                if (mounted) Navigator.of(context).pop();
              });
            },
          ),
        ),
      ),
    );
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
    TextEditingController titleController = TextEditingController(
      text: task.title,
    );
    String selectedCategory = task.category;
    String selectedPriority = task.priority;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 16,
            right: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Edit Task",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 12),

                // Title Field
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Task Title'),
                ),
                SizedBox(height: 12),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedFilterCategory,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Category',
                    border: OutlineInputBorder(),
                  ),
                  items: ['all', ..._categories].map((cat) {
                    return DropdownMenuItem(
                      value: cat, // Use raw lowercase value
                      child: Text(cat.toUpperCase()), // Display uppercase only
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFilterCategory = value!;
                    });
                  },
                ),
                SizedBox(height: 12),

                // Priority Dropdown
                DropdownButtonFormField<String>(
                  value: selectedPriority,
                  decoration: InputDecoration(labelText: 'Priority'),
                  items: ['low', 'medium', 'high'].map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(priority.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedPriority = value!;
                  },
                ),
                SizedBox(height: 16),

                // Save Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        task.title = titleController.text;
                        task.category = selectedCategory;
                        task.priority = selectedPriority;
                      });
                      _saveTasks();
                      Navigator.of(context).pop(); // Close modal
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
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

        // Actually remove task if deleted older version
        // onDismissed: (direction) {
        //   if (direction == DismissDirection.endToStart) {
        //     setState(() {
        //       _tasks.remove(task); // ✅ Correct way to remove by object
        //     });
        //     _saveTasks();
        //     // _showDeleteAnimation(); // 👈 Show animation here
        //   }
        // },
        child: Card(
          elevation: 3,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task Title
                GestureDetector(
                  onTap: () => _editTask(task),
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      decoration: task.done
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Due Date and Time
                if (task.dueDate != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 6),
                        Text(
                          '${task.dueDate!.toLocal().toString().split(' ')[0]}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 6),
                        Text(
                          TimeOfDay.fromDateTime(
                            task.dueDate!.toLocal(),
                          ).format(context),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left: Filter Toggles
                    Row(
                      children: [
                        // Today Only toggle
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
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),

                        // Show/Hide Completed toggle
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _showCompleted = !_showCompleted;
                            });
                          },
                          icon: Icon(
                            _showCompleted
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.blue,
                          ),
                          label: Text(
                            _showCompleted
                                ? 'Hide Completed'
                                : 'Show Completed',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),

                    // Right: Clear All Button
                    if (_tasks.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          if (_tasks.isEmpty) return;

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
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(
                                        context,
                                      ).pop(); // Close the dialog first

                                      setState(() {
                                        _tasks.clear();
                                      });
                                      _saveTasks();

                                      // Delay to ensure dialog is closed before showing animation
                                      Future.delayed(
                                        const Duration(milliseconds: 300),
                                        () {
                                          if (mounted)
                                            _showClearAllDeleteAnimation();
                                        },
                                      );
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
                        icon: Icon(Icons.delete, color: Colors.red),
                        label: Text(
                          'Clear All',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
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
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 1.05),
        duration: Duration(seconds: 1),
        curve: Curves.easeInOut,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        onEnd: () {
          // Loop the animation
          setState(() {});
        },
        child: FloatingActionButton.large(
          backgroundColor: Colors.green,
          elevation: 8,
          onPressed: _showAddTaskBottomSheet,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 28),
              SizedBox(height: 6),
              Text(
                'Add Task',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /////// TAB MY LIST /////////////
  // Tab for displaying tasks (pending + completed)
  Widget _buildTaskListTab() {
    // Separate tasks into pending and completed
    final visibleTasks = _selectedFilterCategory == 'all'
        ? _tasks
        : _tasks
              .where((task) => task.category == _selectedFilterCategory)
              .toList();
    final pendingTasks = visibleTasks.where((task) {
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

    final completedTasks = visibleTasks.where((task) {
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
          const SizedBox(height: 10),

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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Pending Tasks',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Clear Pending Tasks'),
                                  content: Text(
                                    'Are you sure you want to remove all pending tasks?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _tasks.removeWhere(
                                            (task) => !task.done,
                                          );
                                        });
                                        _saveTasks();
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'Clear All',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Text(
                              'Clear All',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
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
                        style: TextStyle(fontWeight: FontWeight.bold),
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
            _tasks.removeAt(index);
          });
          _saveTasks();
          _showDeleteAnimation(); // 🔥 Show animation
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

  void _addTask() async {
    if (_titleController.text.isEmpty) return;

    // 📅 Ask for a date
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (selectedDate == null) return;

    // 🕒 Ask for a time
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime == null) return;

    // ⏱ Combine both into a single DateTime
    DateTime finalDueDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // ✅ Create the new Task
    final newTask = Task(
      title: _titleController.text,
      dueDate: finalDueDate,
      priority: _selectedPriority,
      category: _selectedCategory,
      done: false,
    );

    setState(() {
      _tasks.add(newTask);
      _titleController.clear();
    });

    _saveTasks();
    Navigator.of(context).pop(); // Close bottom sheet

    // Show the animation safely after a short delay
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        _showSuccessAnimation(context); // This handles closing the dialog
      }
    });
  }

  final List<String> _priorities = ['low', 'medium', 'high'];

  void _showAddTaskBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: _buildTaskForm(),
      ),
    );
  }

  Widget _buildTaskForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Add New Task",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(labelText: 'Enter a task today'),
        ),
        SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          items: _categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value!;
            });
          },
          decoration: InputDecoration(labelText: 'Select Category'),
        ),
        SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedPriority,
          items: _priorities.map((String priority) {
            return DropdownMenuItem<String>(
              value: priority,
              child: Text(priority.toUpperCase()),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedPriority = value!;
            });
          },
          decoration: InputDecoration(labelText: 'Select Priority'),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: _addTask,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: Text(
            'Save Task',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 12),
      ],
    );
  }
}
