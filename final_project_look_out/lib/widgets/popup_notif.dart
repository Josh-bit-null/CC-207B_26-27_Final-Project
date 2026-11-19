import 'package:flutter/material.dart';

class PopupNotif {

  final String message;
  final String title;

  const PopupNotif({
    required this.message,
    required this.title,
  });

  void show (BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title: $message'),
      ),
    );
  }

}