import 'package:flutter/material.dart';

class PopupNotif {
  final String message;
  final String title;

  const PopupNotif({required this.message, required this.title});

  void show(BuildContext context) {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.up,
        backgroundColor: theme.colorScheme.inverseSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.only(
         bottom:
              MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              70,
          left: 16,
          right: 16,
        ),
        content: Text(
          '$title: $message',
          style: TextStyle(
            color: theme.colorScheme.onInverseSurface,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
