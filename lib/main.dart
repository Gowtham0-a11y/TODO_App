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

  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
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

  void _addTodo() {
    if (_titleController.text.trim().isEmpty) return;

    setState(() {
      todos.add(
        Todo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          createdAt: DateTime.now(),
        ),
      );
    });

    _titleController.clear();
    _descriptionController.clear();
    Navigator.of(context).pop();
  }

  void _toggleTodo(String id) {
    setState(() {
      final index = todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        todos[index].isCompleted = !todos[index].isCompleted;
      }
    });
  }

  void _deleteTodo(String id) {
    setState(() {
      todos.removeWhere((todo) => todo.id == id);
    });
  }

  void _editTodo(Todo todo) {
    _titleController.text = todo.title;
    _descriptionController.text = todo.description;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Todo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _titleController.clear();
              _descriptionController.clear();
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.trim().isNotEmpty) {
                setState(() {
                  final index = todos.indexWhere((t) => t.id == todo.id);
                  if (index != -1) {
                    todos[index].title = _titleController.text.trim();
                    todos[index].description = _descriptionController.text
                        .trim();
                  }
                });
                _titleController.clear();
                _descriptionController.clear();
                Navigator.of(context).pop();
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showAddTodoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Todo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _titleController.clear();
              _descriptionController.clear();
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(onPressed: _addTodo, child: Text('Add')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedTodos = todos.where((todo) => todo.isCompleted).length;
    final totalTodos = todos.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress indicator
          if (totalTodos > 0)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: completedTodos / totalTodos,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
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
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4),
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
                          subtitle: todo.description.isNotEmpty
                              ? Text(
                                  todo.description,
                                  style: TextStyle(
                                    decoration: todo.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: todo.isCompleted
                                        ? Colors.grey.shade500
                                        : Colors.grey.shade700,
                                  ),
                                )
                              : null,
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
}
