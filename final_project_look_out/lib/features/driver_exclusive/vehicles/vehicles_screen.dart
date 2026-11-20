
import 'package:flutter/material.dart';

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_bus,
            size: 100,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),

          const SizedBox(height: 16),

          Text(
            'Empty',
            style: theme.textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
