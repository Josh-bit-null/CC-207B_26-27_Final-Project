import 'package:final_project_look_out/widgets/lookout_app_bar.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _sections = <({IconData icon, String title, String body})>[
    (
      icon: Icons.location_on_outlined,
      title: 'About the app',
      body:
          'LookOut! is a commuter-focused concept for making public transport '
          'journeys around Iloilo City easier to understand. It brings route '
          'information and vehicle tracking together in benefit for commuters and PUV drivers/conductors.',
    ),
    (
      icon: Icons.groups_outlined,
      title: 'Our team',
      body:
          'LookOut! is a student project created by the Undeciders team.',
    ),
    (
      icon: Icons.favorite_outline,
      title: 'Credits',
      body: 'Map data is provided by OpenStreetMap.',
    ),
    (
      icon: Icons.trending_up,
      title: 'What is next',
      body:
          'Future development may include live vehicle updates, more complete '
          'route and stop information, service announcements, and improved '
          'tools for commuters, drivers, and administrators.',
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
        title:'About LookOut!',
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // App introduction card
          Card(
            elevation: 2,
            color: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 28,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/images/lookoutLogo.png',
                      width: 72,
                      height: 72,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'LookOut!',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Iloilo City Real-Time PUV Tracker',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'About Our Project',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Information sections
          Text(
            'Get to Know LookOut!',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          for (final section in _sections)
            Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 12),
              color: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        section.icon,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            section.body,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Footer
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(height: 6),
                Text(
                  'Made for Iloilo City',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'LookOut! • The Undeciders',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
