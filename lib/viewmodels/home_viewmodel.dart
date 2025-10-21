import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:todo_local/widgets/add_todo.dart';

class HomeViewmodel extends ChangeNotifier {
  late Box _myBox;
  List<String> todoList = []; // ✅ Fixed: Initialize with empty list
  final TextEditingController taskController =
      TextEditingController(); // ✅ Fixed: Made public

  void init() async {
    print('Viewmodel initialized');

    _myBox = await Hive.openBox('myBox');
    print('Hive Box initalized');

    print('Loading Tasks');
    getTask();
    notifyListeners();
  }

  Future<dynamic> showAddTaskDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AddTodo(
          controller: taskController, // ✅ Fixed: Pass controller
          onPressed: () {
            addTask(taskController.text, context); // ✅ Fixed: Pass context
          },
        );
      },
    );
  }

  void addTask(String task, BuildContext context) {
    print('Add Task Button Called');
    if (task.trim().isEmpty) return; // ✅ Added: Validation

    todoList.add(task);
    _myBox.put('todos', todoList);
    taskController.clear();
    Navigator.of(context).pop(); // ✅ Fixed: Close dialog
    notifyListeners();
  }

  void getTask() {
    if (_myBox.containsKey('todos')) {
      // ✅ Fixed: Proper type casting and moved else block
      final dynamic data = _myBox.get('todos');
      if (data is List) {
        todoList = List<String>.from(data);
      } else {
        todoList = [];
      }
    } else {
      todoList = [];
    }
    notifyListeners();
  }

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }
}
