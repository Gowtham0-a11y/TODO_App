import 'package:flutter/material.dart';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TodoHomePage(),
    );
  }
}

class Todo {
  String id;
  String title;
  String description;
  bool isCompleted;
  DateTime createdAt;
  DateTime? dueDate;
  DateTime? dueTime;

  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    this.dueTime,
  });
}

class TodoHomePage extends StatefulWidget {
  @override
  _TodoHomePageState createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  List<Todo> todos = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedDueTime;

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  void _loadSampleData() {
    // Add some sample todos for demonstration
    todos = [
      Todo(
        id: '1',
        title: 'Buy groceries',
        description: 'Milk, bread, eggs, and fruits',
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        dueDate: DateTime.now().add(Duration(days: 1)),
      ),
      Todo(
        id: '2',
        title: 'Complete Flutter project',
        description: 'Finish the todo app implementation',
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
      ),
      Todo(
        id: '3',
        title: 'Call dentist',
        description: 'Schedule appointment for next week',
        createdAt: DateTime.now().subtract(Duration(hours: 3)),
        isCompleted: true,
      ),
    ];
    _sortTodos();
  }

  void _sortTodos() {
    setState(() {
      todos.sort((a, b) {
        // First sort by completion status
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        // Then by due date
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        }
        if (a.dueDate != null) return -1;
        if (b.dueDate != null) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });
    });
  }

  void _addTodo() {
    if (_titleController.text.trim().isEmpty) return;

    DateTime? combinedDateTime;
    if (_selectedDueDate != null && _selectedDueTime != null) {
      combinedDateTime = DateTime(
        _selectedDueDate!.year,
        _selectedDueDate!.month,
        _selectedDueDate!.day,
        _selectedDueTime!.hour,
        _selectedDueTime!.minute,
      );
    }

    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      createdAt: DateTime.now(),
      dueDate: _selectedDueDate,
      dueTime: combinedDateTime,
    );

    setState(() {
      todos.add(todo);
    });
    _clearForm();
    Navigator.of(context).pop();
    _sortTodos();
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _selectedDueDate = null;
    _selectedDueTime = null;
  }

  void _toggleTodo(String id) {
    final index = todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      setState(() {
        todos[index].isCompleted = !todos[index].isCompleted;
      });
      _sortTodos();
    }
  }

  void _deleteTodo(String id) {
    setState(() {
      todos.removeWhere((todo) => todo.id == id);
    });
  }

  void _editTodo(Todo todo) {
    _titleController.text = todo.title;
    _descriptionController.text = todo.description;
    _selectedDueDate = todo.dueDate;
    _selectedDueTime = todo.dueTime != null
        ? TimeOfDay.fromDateTime(todo.dueTime!)
        : null;

    showDialog(
      context: context,
      builder: (context) => _buildTodoDialog(
        title: 'Edit Todo',
        onSave: () {
          if (_titleController.text.trim().isNotEmpty) {
            DateTime? combinedDateTime;
            if (_selectedDueDate != null && _selectedDueTime != null) {
              combinedDateTime = DateTime(
                _selectedDueDate!.year,
                _selectedDueDate!.month,
                _selectedDueDate!.day,
                _selectedDueTime!.hour,
                _selectedDueTime!.minute,
              );
            }

            setState(() {
              todo.title = _titleController.text.trim();
              todo.description = _descriptionController.text.trim();
              todo.dueDate = _selectedDueDate;
              todo.dueTime = combinedDateTime;
            });

            _clearForm();
            Navigator.of(context).pop();
            _sortTodos();
          }
        },
      ),
    );
  }

  void _showAddTodoDialog() {
    _clearForm();
    showDialog(
      context: context,
      builder: (context) =>
          _buildTodoDialog(title: 'Add New Todo', onSave: _addTodo),
    );
  }

  Widget _buildTodoDialog({
    required String title,
    required VoidCallback onSave,
  }) {
    return StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
                autofocus: true,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              // Due date selection
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDueDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
                        if (date != null) {
                          setDialogState(() => _selectedDueDate = date);
                        }
                      },
                      icon: Icon(Icons.calendar_today),
                      label: Text(
                        _selectedDueDate != null
                            ? _formatDateOnly(_selectedDueDate!)
                            : 'Select Date',
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _selectedDueTime ?? TimeOfDay.now(),
                        );
                        if (time != null) {
                          setDialogState(() => _selectedDueTime = time);
                        }
                      },
                      icon: Icon(Icons.access_time),
                      label: Text(
                        _selectedDueTime != null
                            ? _selectedDueTime!.format(context)
                            : 'Select Time',
                      ),
                    ),
                  ),
                ],
              ),
              if (_selectedDueDate != null || _selectedDueTime != null)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: TextButton(
                    onPressed: () {
                      setDialogState(() {
                        _selectedDueDate = null;
                        _selectedDueTime = null;
                      });
                    },
                    child: Text('Clear Date & Time'),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearForm();
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: onSave,
            child: Text(title.contains('Edit') ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  String _formatDateOnly(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour == 0
        ? 12
        : time.hour > 12
        ? time.hour - 12
        : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _formatDateTime(DateTime? date, DateTime? time) {
    if (date == null) return '';

    String result = _formatDateOnly(date);
    if (time != null) {
      result += ' at ${_formatTime(time)}';
    }
    return result;
  }

  bool _isOverdue(DateTime? dueTime) {
    if (dueTime == null) return false;
    return DateTime.now().isAfter(dueTime);
  }

  @override
  Widget build(BuildContext context) {
    final completedTodos = todos.where((todo) => todo.isCompleted).length;
    final totalTodos = todos.length;
    final overdueTodos = todos
        .where((todo) => !todo.isCompleted && _isOverdue(todo.dueTime))
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (overdueTodos > 0)
            Container(
              margin: EdgeInsets.only(right: 16),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$overdueTodos overdue',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          if (totalTodos > 0)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: completedTodos / totalTodos,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        '$completedTodos / $totalTodos completed',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  if (overdueTodos > 0)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        '$overdueTodos overdue tasks',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          // Todo list
          Expanded(
            child: todos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No todos yet!',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the + button to add your first todo',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      final isOverdue = _isOverdue(todo.dueTime);

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        color: isOverdue && !todo.isCompleted
                            ? Colors.red.shade50
                            : null,
                        child: ListTile(
                          leading: Checkbox(
                            value: todo.isCompleted,
                            onChanged: (_) => _toggleTodo(todo.id),
                            activeColor: Colors.green,
                          ),
                          title: Text(
                            todo.title,
                            style: TextStyle(
                              decoration: todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: todo.isCompleted
                                  ? Colors.grey.shade600
                                  : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (todo.description.isNotEmpty)
                                Text(
                                  todo.description,
                                  style: TextStyle(
                                    decoration: todo.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: todo.isCompleted
                                        ? Colors.grey.shade500
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              if (todo.dueDate != null || todo.dueTime != null)
                                Text(
                                  _formatDateTime(todo.dueDate, todo.dueTime),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isOverdue && !todo.isCompleted
                                        ? Colors.red
                                        : Colors.grey.shade600,
                                    fontWeight: isOverdue && !todo.isCompleted
                                        ? FontWeight.bold
                                        : null,
                                  ),
                                ),
                              Text(
                                'Created: ${_formatDateOnly(todo.createdAt)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _editTodo(todo);
                              } else if (value == 'delete') {
                                _deleteTodo(todo.id);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 18),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
