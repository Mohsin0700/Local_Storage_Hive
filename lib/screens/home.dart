import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_local/viewmodels/home_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Color delIconColor = Colors.grey[600]!;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // init sirf ek dafa, aur context safe hone ke baad
      final vm = Provider.of<HomeViewmodel>(context, listen: false);
      vm.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Home View Build');
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.android_sharp),
        title: Text('Offline Todo App'),
      ),
      body: Consumer<HomeViewmodel>(
        builder: (context, vm, child) {
          return ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: vm.todoList.length,
            itemBuilder: (context, index) {
              final task = vm.todoList[index];
              return Card(
                child: ListTile(
                  title: Text(task['task']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          vm.toggleTaskDone(index);
                        },
                        icon: Icon(
                          task['isDone']
                              ? Icons.check_box_outlined
                              : Icons.check_box_outline_blank,
                        ),
                      ),
                      SizedBox(width: 10),
                      IconButton(
                        color: Colors.red,
                        onPressed: () {
                          vm.deleteTask(index);
                        },
                        icon: Icon(Icons.delete),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: ElevatedButton.icon(
        onPressed: () {
          Provider.of<HomeViewmodel>(
            context,
            listen: false,
          ).showAddTaskDialog(context);
        },
        label: Text('Task'),
        icon: Icon(Icons.add),
      ),
      persistentFooterButtons: [
        ElevatedButton.icon(
          icon: Icon(Icons.clear_all),
          onPressed: () {
            Provider.of<HomeViewmodel>(context, listen: false).clearAllTasks();
          },
          label: Text('Clear All Tasks'),
        ),
      ],
    );
  }
}
