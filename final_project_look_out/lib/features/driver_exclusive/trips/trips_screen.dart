import '../../../widgets/lookout_app_bar.dart';
import 'package:flutter/material.dart';

class TripsScreen extends StatelessWidget {

  final VoidCallback? onMenuPressed;

  const TripsScreen({
    super.key,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: LookOutAppBar(
        title: 'My Trips',
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
                    'Trip History',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Review and keep track of your completed and ongoing trips.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _TripCard(
                    route: 'Jaro - Iloilo City Proper',
                    date: 'November 21 · 8:30 AM',
                    passengers: '42 passengers',
                    status: 'Completed',
                  ),
                  const SizedBox(height: 12),
                  _TripCard(
                    route: 'Molo - SM City Iloilo',
                    date: 'November 20 · 5:45 PM',
                    passengers: '36 passengers',
                    status: 'Completed',
                  ),
                  const SizedBox(height: 12),
                  _TripCard(
                    route: 'Leganes - Iloilo City',
                    date: 'November 18 · 7:10 AM',
                    passengers: '28 passengers',
                    status: 'Completed',
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

class _TripCard extends StatelessWidget {
  const _TripCard({
    required this.route,
    required this.date,
    required this.passengers,
    required this.status,
  });

  final String route;
  final String date;
  final String passengers;
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(child: Icon(Icons.route)),
        title: Text(
          route,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text('$date\n$passengers'),
        ),
        trailing: Chip(
          label: Text(status),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
