import '../../../widgets/lookout_app_bar.dart';
import 'package:flutter/material.dart';

class SavedScreen extends StatelessWidget {

  final VoidCallback? onMenuPressed;

  const SavedScreen({
    super.key,
    this.onMenuPressed,  
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: LookOutAppBar(
        title: 'Saved Places',
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
                    'Saved Locations',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Keep your frequently visited places in one convenient location.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SavedPlaceCard(
                    name: 'Central Philippine University',
                    address: 'Jaro, Iloilo City',
                    type: 'School',
                    icon: Icons.school_outlined,
                  ),
                  const SizedBox(height: 12),
                  _SavedPlaceCard(
                    name: 'SM City Iloilo',
                    address: 'Benigno Aquino Avenue, Iloilo City',
                    type: 'Mall',
                    icon: Icons.store_outlined,
                  ),
                  const SizedBox(height: 12),
                  _SavedPlaceCard(
                    name: 'Ungka Terminal',
                    address: 'Jaro, Iloilo City',
                    type: 'Terminal',
                    icon: Icons.directions_bus_outlined,
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

class _SavedPlaceCard extends StatelessWidget {
  const _SavedPlaceCard({
    required this.name,
    required this.address,
    required this.type,
    required this.icon,
  });

  final String name;
  final String address;
  final String type;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: colors.primaryContainer,
          foregroundColor: colors.onPrimaryContainer,
          child: Icon(icon),
        ),
        title: Text(
          name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text('$address · $type'),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
