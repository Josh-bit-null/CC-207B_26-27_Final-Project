import 'package:final_project_look_out/widgets/lookout_app_bar.dart';
import 'package:flutter/material.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  static const _items =
      <({IconData icon, String category, String title, String message, String date})>[
        (
          icon: Icons.directions_bus_outlined,
          category: 'Service update',
          title: 'Welcome to LookOut!',
          message: 'This announcements page is a preview.',
          date: 'LookOut! team',
        ),
        (
          icon: Icons.map_outlined,
          category: 'Coming soon',
          title: 'More route information',
          message: 'We are working toward clearer route and stop information to '
              'help you plan your trips around Iloilo City.',
          date: 'Project update',
        ),
        (
          icon: Icons.tips_and_updates_outlined,
          category: 'App notice',
          title: 'A project in progress',
          message: 'LookOut in development.',
          date: 'LookOut! team',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: LookOutAppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: 'Announcements',
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Updates from LookOut!', style: theme.textTheme.titleLarge),
          Text(
            'Project news and service information.',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 18),
          for (final item in _items)
            Card(
              margin: const EdgeInsets.only(bottom: 14),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(child: Icon(item.icon)),
                        const SizedBox(width: 12),
                        Text(
                          item.category.toUpperCase(),
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(item.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(item.message),
                    const SizedBox(height: 12),
                    Text(
                      item.date,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
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
