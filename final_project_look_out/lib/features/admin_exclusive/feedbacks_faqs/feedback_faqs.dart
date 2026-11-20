import 'package:final_project_look_out/features/admin_exclusive/accounts/accounts_screen.dart';
import 'package:final_project_look_out/features/admin_exclusive/logs/logs_screen.dart';
import 'package:final_project_look_out/widgets/lookout_app_bar.dart';
import 'package:final_project_look_out/widgets/lookout_drawer.dart';
import 'package:flutter/material.dart';

class FeedbackFaqsScreen extends StatelessWidget {
  const FeedbackFaqsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: const LookOutAppBar(title: 'Feedback & FAQs'),
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
                    'Feedback & FAQs',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Review what users are saying and find answers to '
                    'common questions.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _FeedbackMetric(
                        label: 'Feedback received',
                        value: '18',
                        icon: Icons.forum_outlined,
                      ),
                      _FeedbackMetric(
                        label: 'Needs a reply',
                        value: '4',
                        icon: Icons.mark_email_unread_outlined,
                      ),
                      _FeedbackMetric(
                        label: 'Average rating',
                        value: '4.6',
                        icon: Icons.star_outline,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Recent feedback',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final feedback in _sampleFeedback)
                    _FeedbackCard(feedback: feedback),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Frequently asked questions',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${_sampleFaqs.length} articles',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (var index = 0;
                            index < _sampleFaqs.length;
                            index++) ...[
                          if (index > 0) const Divider(height: 1),
                          _FaqTile(faq: _sampleFaqs[index]),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sample feedback and help articles for the admin '
                    'dashboard preview.',
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

class _FeedbackMetric extends StatelessWidget {
  const _FeedbackMetric({
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

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.feedback});

  final _Feedback feedback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusColor = feedback.status == 'Resolved'
        ? Colors.green
        : colors.tertiary;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: colors.secondaryContainer,
                  foregroundColor: colors.onSecondaryContainer,
                  child: Text(feedback.initials),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        feedback.date,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _FeedbackStatus(
                  label: feedback.status,
                  color: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (var star = 1; star <= 5; star++)
                  Icon(
                    star <= feedback.rating ? Icons.star : Icons.star_border,
                    size: 18,
                    color: Colors.amber.shade700,
                  ),
                const SizedBox(width: 8),
                Text(
                  feedback.category,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(feedback.message, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _FeedbackStatus extends StatelessWidget {
  const _FeedbackStatus({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.faq});

  final _Faq faq;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ExpansionTile(
      leading: Icon(Icons.help_outline, color: colors.primary),
      title: Text(faq.question),
      childrenPadding: const EdgeInsets.fromLTRB(56, 0, 20, 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          faq.answer,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Updated ${faq.updated}',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Feedback {
  const _Feedback({
    required this.name,
    required this.initials,
    required this.date,
    required this.rating,
    required this.category,
    required this.status,
    required this.message,
  });

  final String name;
  final String initials;
  final String date;
  final int rating;
  final String category;
  final String status;
  final String message;
}

class _Faq {
  const _Faq({
    required this.question,
    required this.answer,
    required this.updated,
  });

  final String question;
  final String answer;
  final String updated;
}

const _sampleFeedback = [
  _Feedback(
    name: 'Gojo Zenin',
    initials: 'GZ',
    date: 'Today · 9:42 AM',
    rating: 5,
    category: 'Live tracking',
    status: 'Resolved',
    message:
        'The live map made it much easier to see when my ride was arriving.',
  ),
  _Feedback(
    name: 'Zaraki Kenpachi',
    initials: 'ZK',
    date: 'Today · 8:16 AM',
    rating: 3,
    category: 'Route information',
    status: 'Open',
    message:
        'Text Case1, Text Case2, Text Case3.',
  ),
  _Feedback(
    name: 'Marco Lim',
    initials: 'ML',
    date: 'Yesterday · 4:28 PM',
    rating: 5,
    category: 'App experience',
    status: 'Resolved',
    message:
        'Text Example1, Text Example2, Text Example3. Hello Good Job.',
  ),
];

const _sampleFaqs = [
  _Faq(
    question: 'How do I find a nearby ride?',
    answer:
        'Answer will be provided here.',
    updated: 'Nov 18, 2026',
  ),
  _Faq(
    question: 'How can I report a driver or trip issue?',
    answer:
        'Answer will be provided here.',
    updated: 'Nov 12, 2026',
  ),
  _Faq(
    question: 'How do drivers update their availability?',
    answer:
        'Answer will be provided here.',
    updated: 'Nov 8, 2026',
  ),
];
