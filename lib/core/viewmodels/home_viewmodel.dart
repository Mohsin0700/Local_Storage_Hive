import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:todo_local/core/services/lifecycle_manager_service.dart';
import 'package:todo_local/ui/widgets/add_todo.dart';
import 'package:todo_local/ui/widgets/status_dialog.dart';

class HomeViewmodel extends ChangeNotifier {
  late Box _myBox;
  List<Map<String, dynamic>> todoList = [];
  final TextEditingController taskController = TextEditingController();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    _myBox = await Hive.openBox('myBox');

    await _loadTasksFromBox();
    notifyListeners();
    // Lifecycle Management
    LifecycleManager().registerHandler(
      name: 'home-viewmodel',
      onPause: () async {
        await saveAllTasksToHive();
      },
      onResume: () async {
        await _loadTasksFromBox();
        notifyListeners();
      },
      onDetach: () async {
        await Hive.close();
      },
    );
  }

  Future<void> saveAllTasksToHive() async {
    await _myBox.put('todos', todoList);
  }

  Future<void> _loadTasksFromBox() async {
    if (!_myBox.isOpen) return;

    if (!_myBox.containsKey('todos')) {
      todoList = [];
      return;
    }

    final dynamic data = _myBox.get('todos');

    // Normalize into List<Map<String, dynamic>>
    try {
      todoList = _normalizeToTodoList(data);
      // Persist normalized format back to Hive (migration)
      await _myBox.put('todos', todoList);
    } catch (e) {
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
  void addTask(String task, BuildContext context) async {
    if (task.trim().isEmpty) return;
    bool isDuplicate = todoList.any(
      (element) =>
          element['task'].toString().toLowerCase() == task.trim().toLowerCase(),
    );
    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 500),
          backgroundColor: Colors.redAccent,
          content: Text('Task Already Exists'),
        ),
      );
      return;
    }
    todoList.add({'task': task, 'isDone': false});
    _myBox.put('todos', todoList);
    taskController.clear();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: 500),
        backgroundColor: Colors.greenAccent,
        content: Text('Task Added'),
      ),
    );

    notifyListeners();
  }

  void getTask() {
    // public reload if needed
    _loadTasksFromBox().then((_) => notifyListeners());
  }

  void deleteTask(int index, BuildContext context) {
    if (index < 0 || index >= todoList.length) return;
    todoList.removeAt(index);
    _myBox.put('todos', todoList);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: 500),
        backgroundColor: Colors.redAccent,
        content: Text('Task Deleted'),
      ),
    );
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
