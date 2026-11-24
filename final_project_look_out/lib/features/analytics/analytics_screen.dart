import '../../widgets/lookout_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AnalyticsScreen extends StatelessWidget {
  final VoidCallback? onMenuPressed;

  const AnalyticsScreen({super.key, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: LookOutAppBar(title: 'Analytics', onMenuPressed: onMenuPressed),
      body: uid == null
          ? const Center(child: Text('Sign in to view your ride analytics.'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('pokes')
                  .where('fromUid', isEqualTo: uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Unable to load analytics: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final records = snapshot.data?.docs ?? [];
                final routeCounts = <String, int>{};
                final plateCounts = <String, int>{};
                final today = DateTime.now();
                final todayDate = DateTime(today.year, today.month, today.day);
                final dailyCounts = List<int>.filled(7, 0);

                for (final record in records) {
                  final data = record.data();
                  final route = (data['routeId'] as String?)?.trim();
                  final plate = (data['toPlate'] as String?)?.trim();
                  if (route != null && route.isNotEmpty) {
                    routeCounts.update(
                      route,
                      (currentCount) => currentCount + 1,
                      ifAbsent: () => 1,
                    );
                  }
                  if (plate != null && plate.isNotEmpty) {
                    plateCounts.update(
                      plate.toUpperCase(),
                      (currentCount) => currentCount + 1,
                      ifAbsent: () => 1,
                    );
                  }

                  final createdAt = data['createdAt'];
                  if (createdAt is Timestamp) {
                    final created = createdAt.toDate().toLocal();
                    final createdDate = DateTime(
                      created.year,
                      created.month,
                      created.day,
                    );
                    final daysAgo = todayDate.difference(createdDate).inDays;
                    if (daysAgo >= 0 && daysAgo < dailyCounts.length) {
                      dailyCounts[dailyCounts.length - 1 - daysAgo]++;
                    }
                  }
                }

                final topRoute = _mostFrequent(routeCounts);
                final days = List.generate(7, (index) {
                  final date = todayDate.subtract(
                    Duration(days: dailyCounts.length - index - 1),
                  );
                  return _DailyActivity(date: date, count: dailyCounts[index]);
                });

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      'Your Ride Analytics',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A personal summary of the rides and pokes you have logged.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.65,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _MetricCard(
                          title: 'Ride records',
                          value: records.length.toString(),
                          icon: Icons.receipt_long_outlined,
                        ),
                        _MetricCard(
                          title: 'Routes tracked',
                          value: routeCounts.length.toString(),
                          icon: Icons.route_outlined,
                        ),
                        _MetricCard(
                          title: 'Vehicles recorded',
                          value: plateCounts.length.toString(),
                          icon: Icons.directions_bus_outlined,
                        ),
                        _MetricCard(
                          title: 'Most logged route',
                          value: topRoute,
                          icon: Icons.trending_up,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _ActivityCard(days: days, hasRecords: records.isNotEmpty),
                    const SizedBox(height: 20),
                    if (plateCounts.isNotEmpty)
                      _TopVehicleCard(plateCounts: plateCounts),
                  ],
                );
              },
            ),
    );
  }

  String _mostFrequent(Map<String, int> counts) {
    if (counts.isEmpty) return '—';
    return counts.entries
        .reduce((first, second) => first.value >= second.value ? first : second)
        .key;
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: colors.primary),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyActivity {
  const _DailyActivity({required this.date, required this.count});

  final DateTime date;
  final int count;
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.days, required this.hasRecords});

  final List<_DailyActivity> days;
  final bool hasRecords;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final maxCount = days.fold<int>(
      0,
      (maximum, day) => day.count > maximum ? day.count : maximum,
    );
    const weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity · last 7 days',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 118,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final day in days)
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            day.count.toString(),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const Spacer(),
                          Container(
                            width: 20,
                            height: day.count == 0
                                ? 4
                                : 72 * day.count / maxCount,
                            decoration: BoxDecoration(
                              color: day.count == 0
                                  ? colors.surfaceContainerHighest
                                  : colors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            weekdayLabels[day.date.weekday - 1],
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (!hasRecords) ...[
              const SizedBox(height: 8),
              Text(
                'Your activity will appear here after you log a ride.',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TopVehicleCard extends StatelessWidget {
  const _TopVehicleCard({required this.plateCounts});

  final Map<String, int> plateCounts;

  @override
  Widget build(BuildContext context) {
    final topVehicle = plateCounts.entries.reduce(
      (first, second) => first.value >= second.value ? first : second,
    );

    return Card(
      child: ListTile(
        leading: Icon(
          Icons.directions_bus,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text('Most logged vehicle'),
        subtitle: Text(topVehicle.key),
        trailing: Text('${topVehicle.value}'),
      ),
    );
  }
}
