import 'package:final_project_look_out/widgets/lookout_app_bar.dart';
import 'package:final_project_look_out/widgets/lookout_bottom_nav.dart';
import 'package:final_project_look_out/widgets/lookout_drawer.dart';
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
      body:
          'Map data is provided by OpenStreetMap. '
          ,
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
        title: 'About LookOut!',
      ),

      drawer: const LookOutDrawer(
        header: SizedBox.shrink(),
        items: [],
      ),

      bottomNavigationBar: const LookOutBottomNav(),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/lookoutLogo.png',
                    width: 84,
                    height: 84,
                  ),
                  const SizedBox(height: 12),
                  Text('LookOut!', style: theme.textTheme.headlineSmall),
                  const Text(
                    'Iloilo City Real-Time PUV Tracker',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final section in _sections)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(section.icon, color: theme.colorScheme.primary),
                title: Text(section.title),
                subtitle: Text(section.body),
                isThreeLine: true,
              ),
            ),
          const Center(child: Text('Made for Iloilo City')),
        ],
      ),
    );
  }
}
