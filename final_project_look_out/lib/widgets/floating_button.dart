import 'package:flutter/material.dart';

class FloatingButton extends StatelessWidget{

  final IconData icon;
  final VoidCallback onPressed;

  const FloatingButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: Icon(icon),
    );
  }
  
}