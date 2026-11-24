import '../../../widgets/lookout_app_bar.dart';
import 'package:flutter/material.dart';

class VehiclesScreen extends StatelessWidget {

  final VoidCallback? onMenuPressed;

  const VehiclesScreen({
    super.key,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: LookOutAppBar(
        title: 'My Vehicles',
        onMenuPressed: onMenuPressed,
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assigned Vehicles',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'View the public utility vehicles assigned to your account.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: colors.primaryContainer,
                  child: Icon(
                    Icons.directions_bus,
                    color: colors.onPrimaryContainer,
                  ),
                ),
                title: const Text(
                  'ABC 1234',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('Modern Jeepney\nRoute: Jaro - City Proper'),
                ),
                trailing: const Chip(label: Text('Active')),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: colors.secondaryContainer,
                  child: Icon(
                    Icons.directions_bus,
                    color: colors.onSecondaryContainer,
                  ),
                ),
                title: const Text(
                  'XYZ 5678',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('Mini Bus\nRoute: Molo - SM City Iloilo'),
                ),
                trailing: const Chip(label: Text('Available')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
