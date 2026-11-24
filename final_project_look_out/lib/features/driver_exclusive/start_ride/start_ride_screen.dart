import '../../../widgets/lookout_app_bar.dart';
import 'package:flutter/material.dart';

class StartRideScreen extends StatelessWidget {

  final VoidCallback? onMenuPressed;

  const StartRideScreen({
    super.key,
     this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: LookOutAppBar(
        title: 'Start a Ride',
        onMenuPressed: onMenuPressed,
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ride Management',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Prepare the route and vehicle details before starting a trip.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const TextField(
                            decoration: InputDecoration(
                              labelText: 'Route',
                              hintText: 'Jaro - Iloilo City Proper',
                              prefixIcon: Icon(Icons.route),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const TextField(
                            decoration: InputDecoration(
                              labelText: 'Vehicle',
                              hintText: 'Jeepney · ABC 1234',
                              prefixIcon: Icon(Icons.directions_bus),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const TextField(
                            decoration: InputDecoration(
                              labelText: 'Departure Time',
                              hintText: '8:30 AM',
                              prefixIcon: Icon(Icons.schedule),
                            ),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: null,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start Ride'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
