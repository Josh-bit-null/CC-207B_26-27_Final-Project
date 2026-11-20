import 'package:final_project_look_out/features/admin_exclusive/accounts/accounts_screen.dart';
import 'package:final_project_look_out/features/admin_exclusive/feedbacks_faqs/feedback_faqs.dart';
import 'package:final_project_look_out/widgets/lookout_app_bar.dart';
import 'package:final_project_look_out/widgets/lookout_drawer.dart';
import 'package:flutter/material.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: const LookOutAppBar(title: 'Activity Logs'),
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
                MaterialPageRoute(builder: (context) => const AccountsScreen()),
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
                    'Activity Monitoring',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A record of recent actions across the LookOut! system.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _LogMetric(
                        label: 'Events today',
                        value: '126',
                        icon: Icons.receipt_long_outlined,
                      ),
                      _LogMetric(
                        label: 'Admin actions',
                        value: '8',
                        icon: Icons.admin_panel_settings_outlined,
                      ),
                      _LogMetric(
                        label: 'Alerts',
                        value: '2',
                        icon: Icons.warning_amber_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Recent activity',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Latest first',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  for (var index = 0; index < _sampleLogs.length; index++) ...[
                    if (index == 0 ||
                        _sampleLogs[index].date != _sampleLogs[index - 1].date)
                      _LogDateHeading(date: _sampleLogs[index].date),
                    _ActivityLogTile(
                      log: _sampleLogs[index],
                      isLast: index == _sampleLogs.length - 1,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Sample activity data for the admin dashboard preview.',
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

class _LogMetric extends StatelessWidget {
  const _LogMetric({
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
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogDateHeading extends StatelessWidget {
  const _LogDateHeading({required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 2),
      child: Text(
        date,
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ActivityLogTile extends StatelessWidget {
  const _ActivityLogTile({required this.log, required this.isLast});

  final _ActivityLog log;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = switch (log.type) {
      'Account' => colors.primary,
      'Feedback' => colors.tertiary,
      'Alert' => colors.error,
      _ => Colors.green,
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 42,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: accent.withValues(alpha: 0.12),
                  foregroundColor: accent,
                  child: Icon(log.icon, size: 19),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: colors.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            log.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          log.time,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(log.description, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 15,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            log.actor,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        _LogTypeTag(label: log.type, color: accent),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogTypeTag extends StatelessWidget {
  const _LogTypeTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ActivityLog {
  const _ActivityLog({
    required this.date,
    required this.time,
    required this.title,
    required this.description,
    required this.actor,
    required this.type,
    required this.icon,
  });

  final String date;
  final String time;
  final String title;
  final String description;
  final String actor;
  final String type;
  final IconData icon;
}

const _sampleLogs = [
  _ActivityLog(
    date: 'Today · November 20, 2026',
    time: '10:24 AM',
    title: 'Account status updated',
    description: 'Devin Kurant’s account was approved.',
    actor: 'Admin · Joshu Pang',
    type: 'Account',
    icon: Icons.person_add_alt_1_outlined,
  ),
  _ActivityLog(
    date: 'Today · November 20, 2026',
    time: '9:51 AM',
    title: 'Feedback marked as resolved',
    description: 'A response was recorded for live tracking feedback.',
    actor: 'Admin · Joshu Pang',
    type: 'Feedback',
    icon: Icons.mark_email_read_outlined,
  ),
  _ActivityLog(
    date: 'Today · November 20, 2026',
    time: '8:37 AM',
    title: 'New driver registration',
    description: 'A new driver submitted an account for review.',
    actor: 'System',
    type: 'Account',
    icon: Icons.badge_outlined,
  ),
  _ActivityLog(
    date: 'Yesterday · November 19, 2026',
    time: '6:12 PM',
    title: 'Unusual sign-in attempt',
    description:
        'Several unsuccessful sign-in attempts were detected for one account.',
    actor: 'System security',
    type: 'Alert',
    icon: Icons.shield_outlined,
  ),
  _ActivityLog(
    date: 'Yesterday · November 19, 2026',
    time: '3:06 PM',
    title: 'FAQ article updated',
    description: '“How do I find a nearby ride?” was edited.',
    actor: 'Admin · Joshu Pang.',
    type: 'Content',
    icon: Icons.edit_note_outlined,
  ),
];
