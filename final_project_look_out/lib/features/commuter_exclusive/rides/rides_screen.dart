import 'package:final_project_look_out/features/commuter_exclusive/saved/saved_screen.dart';
import 'package:final_project_look_out/widgets/lookout_app_bar.dart';
import 'package:final_project_look_out/widgets/lookout_drawer.dart';
import 'package:flutter/material.dart';

class RidesScreen extends StatelessWidget {
  const RidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: const LookOutAppBar(title: 'My Rides'),

      drawer: LookOutDrawer(
        header: Padding(
          padding: const EdgeInsets.all(16),
          child: Image.asset('assets/images/lookoutBanner.png', height: 60),
        ),
        items: [
          ListTile(
            leading: const Icon(Icons.emoji_transportation),
            title: const Text('Rides'),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RidesScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.save),
            title: const Text('Saved'),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SavedScreen()),
              );
            },
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8),
            child: IconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ride History',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'View and keep track of your previous and ongoing rides.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _RideCard(
                    route: 'Jaro - Iloilo City Proper',
                    date: 'November 21, 2026 · 8:30 AM',
                    vehicle: 'Jeepney · ABC 1234',
                    status: 'Completed',
                    fare: '₱18.00',
                  ),
                  const SizedBox(height: 12),
                  _RideCard(
                    route: 'Molo - SM City Iloilo',
                    date: 'November 20, 2026 · 5:45 PM',
                    vehicle: 'Modern Jeepney · XYZ 5678',
                    status: 'Completed',
                    fare: '₱25.00',
                  ),
                  const SizedBox(height: 12),
                  _RideCard(
                    route: 'Leganes - Iloilo City',
                    date: 'November 18, 2026 · 7:10 AM',
                    vehicle: 'Mini Bus · LPT 4321',
                    status: 'Completed',
                    fare: '₱30.00',
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

class _RideCard extends StatelessWidget {
  const _RideCard({
    required this.route,
    required this.date,
    required this.vehicle,
    required this.status,
    required this.fare,
  });

  final String route;
  final String date;
  final String vehicle;
  final String status;
  final String fare;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.route, color: colors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    route,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  fare,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(date, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              vehicle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Chip(label: Text(status), visualDensity: VisualDensity.compact),
          ],
        ),
      ),
    );
  }
}
