import 'package:final_project_look_out/features/admin_exclusive/feedbacks_faqs/feedback_faqs.dart';
import 'package:final_project_look_out/features/admin_exclusive/logs/logs_screen.dart';
import 'package:final_project_look_out/widgets/lookout_app_bar.dart';
import 'package:final_project_look_out/widgets/lookout_drawer.dart';
import 'package:flutter/material.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: const LookOutAppBar(title: 'User Accounts'),
      drawer: LookOutDrawer(
        header: Padding(
          padding: const EdgeInsets.all(16),
          child: Image.asset('assets/images/lookoutBanner.png', height: 60),
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
            title: const Text('Feedback & FAQs'),
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
                MaterialPageRoute(builder: (context) => const LogsScreen()),
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
                    'Account Management',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage and monitor registered LookOut accounts.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _AccountMetric(
                        label: 'Total accounts',
                        value: '248',
                        icon: Icons.people_outline,
                      ),
                      _AccountMetric(
                        label: 'Active',
                        value: '231',
                        icon: Icons.check_circle_outline,
                      ),
                      _AccountMetric(
                        label: 'Pending review',
                        value: '12',
                        icon: Icons.pending_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Registered users',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '5 shown',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final account in _sampleAccounts)
                    _AccountCard(account: account),
                  const SizedBox(height: 8),
                  Text(
                    'Sample account data for the admin dashboard preview.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
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

class _AccountMetric extends StatelessWidget {
  const _AccountMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 50) / 2,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: colors.primary),
              const SizedBox(height: 10),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account});

  final _Account account;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusColor = switch (account.status) {
      'Active' => Colors.green,
      'Pending' => Colors.orange,
      _ => colors.error,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colors.primaryContainer,
              foregroundColor: colors.onPrimaryContainer,
              child: Text(account.initials),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    account.email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _AccountTag(label: account.role),
                      _AccountTag(
                        label: account.status,
                        color: statusColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.more_vert, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _AccountTag extends StatelessWidget {
  const _AccountTag({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tagColor = color ?? colors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: tagColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: tagColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Account {
  const _Account({
    required this.name,
    required this.initials,
    required this.email,
    required this.role,
    required this.status,
  });

  final String name;
  final String initials;
  final String email;
  final String role;
  final String status;
}

const _sampleAccounts = [
  _Account(
    name: 'Naruto Uzumaki',
    initials: 'NU',
    email: 'naruto.uzumaki@email.com',
    role: 'Commuter',
    status: 'Active',
  ),
  _Account(
    name: 'Joshuwa Clint',
    initials: 'JC',
    email: 'joshuwa.clint@email.com',
    role: 'Driver',
    status: 'Active',
  ),
  _Account(
    name: 'Devin Kurant',
    initials: 'DK',
    email: 'devin.kurant@email.com',
    role: 'Commuter',
    status: 'Pending',
  ),
  _Account(
    name: 'Doe John',
    initials: 'DJ',
    email: 'doe.john@email.com',
    role: 'Driver',
    status: 'Suspended',
  ),
  _Account(
    name: 'Dane Joe',
    initials: 'DJ',
    email: 'dane.joe@email.com',
    role: 'Commuter',
    status: 'Active',
  ),
];
