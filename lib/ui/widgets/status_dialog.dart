import 'package:flutter/material.dart';

class StatusDialog extends StatelessWidget {
  final bool isSuccess;
  const StatusDialog({super.key, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: isSuccess ? Colors.green[100] : Colors.red[100],
      title: Text(isSuccess ? 'Success' : 'Error'),
      content: Text(
        isSuccess ? 'Task added successfully!' : 'Failed to add task.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
