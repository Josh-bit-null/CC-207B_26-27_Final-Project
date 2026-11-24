import '../start_ride/start_ride_screen.dart';
import '../vehicles/vehicles_screen.dart';
import '../../../widgets/lookout_app_bar.dart';
import '../../../widgets/lookout_drawer.dart';
import 'package:flutter/material.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: const LookOutAppBar(title: 'My Trips'),

      drawer: LookOutDrawer(
        header: Padding(
          padding: const EdgeInsets.all(16),
          child: Image.asset('assets/images/lookoutBanner.png', height: 60),
        ),
        items: [
          ListTile(
            leading: const Icon(Icons.play_circle),
            title: const Text('Start Ride'),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StartRideScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.route),
            title: const Text('Trips'),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TripsScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.directions_bus),
            title: const Text('Vehicles'),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VehiclesScreen()),
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
