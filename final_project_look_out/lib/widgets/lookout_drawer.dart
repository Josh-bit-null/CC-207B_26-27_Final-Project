import 'package:flutter/material.dart';

class LookOutDrawer extends StatelessWidget {

  final Widget header;
  final List<Widget> items;

  const LookOutDrawer({
    super.key,
    required this.items,
    required this.header,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          header,
          ...items,
        ],
      ),
    );
  }
}
