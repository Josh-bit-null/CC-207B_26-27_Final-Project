import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {

  const ConfirmationDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Confirm Action'),
      content: Text('Are you sure?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          }, 
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, true);
          }, 
          child: Text('Confirm'),
        ),
      ],
    );
  }
}