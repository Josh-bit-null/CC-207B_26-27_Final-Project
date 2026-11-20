import 'package:final_project_look_out/features/about/about_screen.dart';
import 'package:final_project_look_out/features/admin_exclusive/accounts/accounts_screen.dart';
import 'package:final_project_look_out/features/admin_exclusive/feedbacks_faqs/feedback_faqs.dart';
import 'package:final_project_look_out/features/admin_exclusive/logs/logs_screen.dart';
import 'package:final_project_look_out/features/analytics/analytics_screen.dart';
import 'package:final_project_look_out/features/announcements/announcements_screen.dart';
import 'package:final_project_look_out/features/profile/profile_screen.dart';
import 'package:final_project_look_out/widgets/lookout_app_bar.dart';
import 'package:final_project_look_out/widgets/lookout_bottom_nav.dart';
import 'package:final_project_look_out/widgets/lookout_drawer.dart';
import 'package:flutter/material.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // App Bar
      appBar: selectedIndex == 0
      ? const LookOutAppBar(
        title: 'Admin Dashboard',
      )
      : null,

      // Drawer
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
            leading: const Icon(Icons.account_box),
            title: const Text('Accounts'),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountsScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Feeback FAQs'),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FeedbackFaqsScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Logs'),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LogsScreen(),
                ),
              );
            },
          ),
        ],
      ),

      // Bottom Navigation
       bottomNavigationBar: LookOutBottomNav(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index){
          setState(() {
            selectedIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home), 
            label: 'Home'
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info), 
            label: 'About'
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics), 
            label: 'Analytics'
          ),
          NavigationDestination(
            icon: Icon(Icons.announcement_outlined),
            selectedIcon: Icon(Icons.announcement), 
            label: 'Announcement'
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person), 
            label: 'Profile'
          ),
        ],
      ),

      // Dashboard Body
      body: IndexedStack(
        index: selectedIndex,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Text(
                  'Welcome, Admin!',
                  style: theme.textTheme.headlineMedium,
                ),

                const SizedBox(height: 6),

                Text(
                  'Manage and monitor your LookOut! system.',
                  style: theme.textTheme.bodyMedium,
                ),

                const SizedBox(height: 24),

                // System Overview
                Text(
                  'System Overview',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // Summary Cards
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: const [
                    AdminSummaryCard(
                      title: 'Total Users',
                      value: '—',
                      icon: Icons.people_outline,
                    ),
                    AdminSummaryCard(
                      title: 'Total Drivers',
                      value: '—',
                      icon: Icons.person_outline,
                    ),
                    AdminSummaryCard(
                      title: 'Registered Vehicles',
                      value: '—',
                      icon: Icons.directions_bus_outlined,
                    ),
                    AdminSummaryCard(
                      title: 'Active Trips',
                      value: '—',
                      icon: Icons.route_outlined,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Management Section
                Text(
                  'Management',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // User Accounts
                _buildManagementCard(
                  context,
                  icon: Icons.manage_accounts_outlined,
                  title: 'User Accounts',
                  subtitle: 'Manage registered user accounts',
                ),

                // Feedback and FAQs
                _buildManagementCard(
                  context,
                  icon: Icons.feedback_outlined,
                  title: 'Feedback and FAQs',
                  subtitle: 'Review feedback and frequently asked questions',
                ),

                // Activity Logs
                _buildManagementCard(
                  context,
                  icon: Icons.history,
                  title: 'Activity Logs',
                  subtitle: 'Monitor recorded system activities',
                ),

                // Ride Monitoring
                _buildManagementCard(
                  context,
                  icon: Icons.directions_bus_outlined,
                  title: 'Ride Monitoring',
                  subtitle: 'View and monitor trip activities',
                ),

                const SizedBox(height: 20),

                // Recent Activity Section
                Text(
                  'Recent Activity',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Card(
                  elevation: 1,
                  color: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.history,
                            size: 36,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No recent activity available',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Activity records will appear here when available.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
          const AboutScreen(),
          const AnalyticsScreen(),
          const AnnouncementsScreen(),
          const ProfileScreen(
              name: 'Commuter', 
              email: 'commuter@lookout.ph', 
              role: 'commmuter'
            ),
        ],
      )
    );
  }

  // Reusable Management Card
  Widget _buildManagementCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            icon,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}

// Reusable Admin Summary Card
class AdminSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const AdminSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: (MediaQuery.of(context).size.width - 44) / 2,
      child: Card(
        elevation: 1,
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 28,
                color: theme.colorScheme.primary,
              ),

              const SizedBox(height: 14),

              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                title,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
