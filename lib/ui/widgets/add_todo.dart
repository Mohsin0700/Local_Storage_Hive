import 'package:flutter/material.dart';

class AddTodo extends StatelessWidget {
  final TextEditingController? controller;
  final void Function()? onPressed;
  const AddTodo({super.key, this.controller, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Todo'),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: 'Enter todo title'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(onPressed: onPressed, child: Text('Add')),
      ],
    );
  }
}
