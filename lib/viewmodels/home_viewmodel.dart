import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:todo_local/widgets/add_todo.dart';

class HomeViewmodel extends ChangeNotifier {
  late Box _myBox;
  late List<String> todoList;
  final TextEditingController _taskController = TextEditingController();
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
        return AddTodo(onPressed: () => addTask(_taskController.text));
      },
    );
  }

  void addTask(String task) {
    print('Add Task Button Called');
    todoList.add(task);
    _myBox.put('todos', todoList);
    _taskController.clear();
    notifyListeners();
  }

  void getTask() {
    if (_myBox.containsKey('todos')) {
      todoList = _myBox.get('todos');
    }
    todoList = [];
    notifyListeners();
  }
}
