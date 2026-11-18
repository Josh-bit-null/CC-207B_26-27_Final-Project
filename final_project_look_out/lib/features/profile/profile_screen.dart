import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.role,
  });

  final String name, email, role;
  String get _displayName => name.trim().isNotEmpty
      ? name.trim()
      : email.contains('@')
      ? email.split('@').first
      : 'LookOut! user';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _displayName
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map((word) => word[0])
        .take(2)
        .join()
        .toUpperCase();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('My Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                    child: Text(initials.isEmpty ? 'U' : initials),
                  ),
                  const SizedBox(height: 14),
                  Text(_displayName, style: theme.textTheme.titleLarge),
                  Text(role.toUpperCase()),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Account details'),
          ),
          _detail(context, Icons.person_outline, 'Name', _displayName),
          _detail(context, Icons.email_outlined, 'Email', email),
          _detail(
            context,
            Icons.badge_outlined,
            'Account type',
            role.isEmpty ? 'Not specified' : role,
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.verified_user_outlined),
              title: Text('Your LookOut! account'),
              subtitle: Text(
                'Your profile information is shown for this session.',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detail(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) => Card(
    child: ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      subtitle: Text(value.isEmpty ? 'Not provided' : value),
    ),
  );
}
