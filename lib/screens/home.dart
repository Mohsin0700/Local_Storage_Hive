import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_local/viewmodels/home_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeViewmodel homeViewmodel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeViewmodel = Provider.of<HomeViewmodel>(context, listen: false);
      homeViewmodel.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Home View Build');

    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.android_sharp),
        title: Text('Todo Hive'),
      ),
      body: ListView.builder(
        itemCount: homeViewmodel.todoList.length,
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              children: [Text('Task ${homeViewmodel.todoList[index]}')],
            ),
          );
        },
      ),
      floatingActionButton: ElevatedButton.icon(
        onPressed: () {
          homeViewmodel.showAddTaskDialog(context);
        },
        label: Text('Task'),
        icon: Icon(Icons.add),
      ),
    );
  }
}
