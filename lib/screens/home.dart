import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_local/viewmodels/home_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Color delIconColor = Colors.grey[600]!;

  @override
  void initState() {
    super.initState();
    // context safe hone ke baad ek dafa initialize karna
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<HomeViewmodel>(context, listen: false);
      vm.init();
    });
  }

  // Breakpoints
  static const double mobileBreakpoint = 600; // phone
  static const double tabletBreakpoint = 1024; // small/large tablet

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < mobileBreakpoint;
    final isTablet = width >= mobileBreakpoint && width < tabletBreakpoint;
    final isLargeTablet = width >= tabletBreakpoint;

    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.android_sharp),
        title: Text('Offline Task Manager'),
        actions: [
          // On wide screens show Clear All as action, on small show footer button
          if (!isMobile)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton.icon(
                icon: Icon(Icons.clear_all),
                onPressed: () {
                  Provider.of<HomeViewmodel>(
                    context,
                    listen: false,
                  ).clearAllTasks();
                },
                label: Text('Clear All'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
        ],
      ),
      // Use Consumer with proper typing
      body: Consumer<HomeViewmodel>(
        builder: (context, vm, child) {
          // Responsive padding & layout
          final horizontalPadding = isMobile ? 8.0 : (isTablet ? 24.0 : 40.0);
          final verticalPadding = isMobile ? 8.0 : 16.0;

          // If large tablet -> show grid cards, tablet -> 2-col grid, mobile -> list
          if (isLargeTablet) {
            final crossCount = 3;
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3,
                ),
                itemCount: vm.todoList.length,
                itemBuilder: (context, index) {
                  final task = vm.todoList[index];
                  return _buildCard(vm, task, index, isMobile);
                },
              ),
            );
          }

          if (isTablet) {
            final crossCount = 2;
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 4,
                ),
                itemCount: vm.todoList.length,
                itemBuilder: (context, index) {
                  final task = vm.todoList[index];
                  return _buildCard(vm, task, index, isMobile);
                },
              ),
            );
          }

          // Mobile / default: ListView
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: vm.todoList.length,
              itemBuilder: (context, index) {
                final task = vm.todoList[index];
                return _buildCard(vm, task, index, isMobile);
              },
            ),
          );
        },
      ),
      // Use an adaptive FAB that looks good on all sizes
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Provider.of<HomeViewmodel>(
            context,
            listen: false,
          ).showAddTaskDialog(context);
        },
        icon: Icon(Icons.add),
        label: Text('Add Task'),
      ),
      // On mobile show footer action; tablet/desktop use appBar button
      persistentFooterButtons: isMobile
          ? [
              ElevatedButton.icon(
                icon: Icon(Icons.clear_all),
                onPressed: () {
                  Provider.of<HomeViewmodel>(
                    context,
                    listen: false,
                  ).clearAllTasks();
                },
                label: Text('Clear All Tasks'),
              ),
            ]
          : null,
    );
  }

  // Single card builder to keep UI consistent between list/grid
  Widget _buildCard(
    HomeViewmodel vm,
    Map<String, dynamic> task,
    int index,
    bool isMobile,
  ) {
    final titleStyle = isMobile
        ? TextStyle(fontSize: 16)
        : TextStyle(fontSize: 18, fontWeight: FontWeight.w600);

    // Larger tap targets for tablet
    final iconSize = isMobile ? 24.0 : 28.0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 16,
            vertical: 4,
          ),
          title: Text(task['task'] ?? '', style: titleStyle),
          subtitle: task['note'] != null ? Text(task['note']) : null,
          leading: IconButton(
            onPressed: () => vm.toggleTaskDone(index),
            iconSize: iconSize,
            icon: Icon(
              task['isDone']
                  ? Icons.check_box_outlined
                  : Icons.check_box_outline_blank,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Optional: show due date or priority on wider screens
              if (!isMobile && task.containsKey('due') && task['due'] != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(task['due'].toString()),
                ),
              IconButton(
                onPressed: () => vm.deleteTask(index),
                icon: Icon(Icons.delete),
                color: delIconColor,
                iconSize: iconSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
