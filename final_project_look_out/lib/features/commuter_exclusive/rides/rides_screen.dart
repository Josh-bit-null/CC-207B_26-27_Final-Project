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
      appBar: const LookOutAppBar(
        title: 'My Rides',
      ),

      drawer: LookOutDrawer(
        header: Padding(
          padding: const EdgeInsets.all(16),
          child: Image.asset(
            'assets/images/lookoutBanner.png',
            height: 60,
          ),
        ),
        items: [
          ListTile(
            leading: const Icon(Icons.emoji_transportation),
            title: const Text('Rides'),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RidesScreen(),
                ),
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
                MaterialPageRoute(
                  builder: (context) => const SavedScreen(),
                ),
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

                  Card(
                    elevation: 1,
                    color: colors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.directions_car_outlined,
                              size: 30,
                              color: colors.onPrimaryContainer,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Rides',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  'Your ride information and records will appear here.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 40,
                        horizontal: 16,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.route_outlined,
                            size: 58,
                            color: colors.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'Ride Records',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Your previous and ongoing ride records will be displayed here.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
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
