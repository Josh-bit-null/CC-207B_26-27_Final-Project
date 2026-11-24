import '../../widgets/lookout_app_bar.dart';
import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  final VoidCallback? onMenuPressed;

  const AnalyticsScreen({super.key, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: LookOutAppBar(title: 'Analytics', onMenuPressed: onMenuPressed),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 100,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),

            const SizedBox(height: 16),

            Text('Empty', style: theme.textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
