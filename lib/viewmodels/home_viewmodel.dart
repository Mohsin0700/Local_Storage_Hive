import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:todo_local/widgets/add_todo.dart';

class HomeViewmodel extends ChangeNotifier {
  late Box _myBox;
  List<Map<String, dynamic>> todoList = [];
  final TextEditingController taskController = TextEditingController();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    print('Viewmodel initialized');

    _myBox = await Hive.openBox('myBox');
    print('Hive Box initialized');

    print('Loading Tasks');
    await _loadTasksFromBox();
    notifyListeners();
  }

  Future<void> _loadTasksFromBox() async {
    if (!_myBox.isOpen) return;

    if (!_myBox.containsKey('todos')) {
      todoList = [];
      print('No todos key found, starting with empty list.');
      return;
    }

    final dynamic data = _myBox.get('todos');
    print('Raw data from box: $data (type: ${data.runtimeType})');

    // Normalize into List<Map<String, dynamic>>
    try {
      todoList = _normalizeToTodoList(data);
      print('Normalized todoList: $todoList');
      // Persist normalized format back to Hive (migration)
      await _myBox.put('todos', todoList);
      print('Migrated/stored normalized todos back to Hive.');
    } catch (e, st) {
      print('Failed to normalize todos from Hive: $e\n$st');
      // fallback to empty
      todoList = [];
    }
  }

  // Helper method to normalize various stored formats into List<Map<String, dynamic>>
  List<Map<String, dynamic>> _normalizeToTodoList(dynamic data) {
    // If data already List<Map>, try to cast safely
    if (data is List) {
      final List<Map<String, dynamic>> out = [];
      for (var item in data) {
        if (item is Map) {
          // ensure Map<String, dynamic>
          out.add(Map<String, dynamic>.from(item));
        } else if (item is String) {
          // treat it as plain task string
          out.add({'task': item, 'isDone': false});
        } else {
          // unknown element type: try converting by toString()
          out.add({'task': item.toString(), 'isDone': false});
        }
      }
      return out;
    }

    // If data is a String it might be a JSON encoded list or single task
    if (data is String) {
      final trimmed = data.trim();
      // try parse as JSON
      try {
        final decoded = jsonDecode(trimmed);
        // recursively normalize decoded value
        return _normalizeToTodoList(decoded);
      } catch (_) {
        // not JSON — treat as single task string
        return [
          {'task': data, 'isDone': false},
        ];
      }
    }

    // If it's a Map (single task saved wrongly), convert to list
    if (data is Map) {
      return [Map<String, dynamic>.from(data)];
    }

    // anything else — make safe fallback
    return [];
  }

  // Helper method to show AddTaskDialog
  Future<dynamic> showAddTaskDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AddTodo(
          controller: taskController,
          onPressed: () {
            addTask(taskController.text, context);
          },
        );
      },
    );
  }

  // Helper method to add task
  void addTask(String task, BuildContext context) {
    print('Add Task Button Called');
    if (task.trim().isEmpty) return;

    todoList.add({'task': task, 'isDone': false});
    _myBox.put('todos', todoList);
    taskController.clear();
    Navigator.of(context).pop();
    notifyListeners();
  }

  void getTask() {
    // public reload if needed
    _loadTasksFromBox().then((_) => notifyListeners());
  }

  void deleteTask(int index) {
    if (index < 0 || index >= todoList.length) return;
    todoList.removeAt(index);
    _myBox.put('todos', todoList);
    notifyListeners();
  }

  void toggleTaskDone(int index) {
    if (index < 0 || index >= todoList.length) return;
    todoList[index]['isDone'] = !(todoList[index]['isDone'] as bool);
    _myBox.put('todos', todoList);
    notifyListeners();
  }

  void clearAllTasks() {
    todoList.clear();
    _myBox.put('todos', todoList);
    notifyListeners();
  }

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }
}
