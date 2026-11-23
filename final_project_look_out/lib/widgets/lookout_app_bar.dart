import 'package:flutter/material.dart';

class LookOutAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final bool isBottomNav;
  final VoidCallback? onMenuPressed;

  const LookOutAppBar({
    super.key,
    required this.title,
    this.leading,
    this.isBottomNav = true,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: isBottomNav
      ? Builder(
        builder: (context) => IconButton(
          tooltip: 'Menu',
          icon: const Icon(Icons.menu),
          onPressed: onMenuPressed ??
            () => Scaffold.of(context).openDrawer(), 
          ),
        )
        : leading,

      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}