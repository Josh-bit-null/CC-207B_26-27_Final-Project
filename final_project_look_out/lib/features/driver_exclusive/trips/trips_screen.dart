import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../services/local_bus_tracking_service.dart';
import '../../../widgets/lookout_app_bar.dart';

class TripsScreen extends StatelessWidget {
  final VoidCallback? onMenuPressed;

  const TripsScreen({super.key, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final tracking = LocalBusTrackingService.instance;

    return Scaffold(
      appBar: LookOutAppBar(title: 'My Trips', onMenuPressed: onMenuPressed),
      body: uid == null
          ? const Center(child: Text('Sign in to view your trips.'))
          : ValueListenableBuilder<List<DriverTrip>>(
              valueListenable: tracking.completedTrips,
              builder: (context, allTrips, _) {
                final trips = allTrips
                    .where((trip) => trip.driverId == uid)
                    .toList();
                final totalDuration = trips.fold<Duration>(
                  Duration.zero,
                  (total, trip) => total + trip.duration,
                );

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      'Trip History',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Review trips completed during this app session.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _TripSummaryCard(
                          title: 'Completed trips',
                          value: '${trips.length}',
                          icon: Icons.check_circle_outline,
                        ),
                        _TripSummaryCard(
                          title: 'Time on road',
                          value: _formatDuration(totalDuration),
                          icon: Icons.schedule,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Recent trips', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 12),
                    if (trips.isEmpty)
                      const Card(
                        child: ListTile(
                          leading: Icon(Icons.route_outlined),
                          title: Text('No completed trips this session.'),
                          subtitle: Text(
                            'Start and end a ride to record it here.',
                          ),
                        ),
                      )
                    else
                      ...trips.map(
                        (trip) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TripCard(trip: trip),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Trip history is stored in memory and clears when the app closes.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip});

  final DriverTrip trip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: colors.onPrimaryContainer,
                  child: const Icon(Icons.route),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    trip.routeName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Chip(
                  label: Text('Completed'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Vehicle: ${trip.plateNumber}'),
            const SizedBox(height: 4),
            Text('Started: ${_formatDateTime(trip.startedAt)}'),
            Text('Ended: ${_formatDateTime(trip.endedAt)}'),
            const SizedBox(height: 8),
            Text(
              'Duration: ${_formatDuration(trip.duration)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripSummaryCard extends StatelessWidget {
  const _TripSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = (MediaQuery.sizeOf(context).width - 52) / 2;

    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.year}-$month-$day $hour:$minute';
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}
