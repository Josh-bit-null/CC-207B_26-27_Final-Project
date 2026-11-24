import 'package:final_project_look_out/widgets/floating_button.dart';

import '../../../widgets/lookout_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SavedScreen extends StatefulWidget {

  final VoidCallback? onMenuPressed;

  const SavedScreen({
    super.key,
    this.onMenuPressed,  
  });

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _db.collection('users').doc(uid);

  List<Map<String, dynamic>> _savedPlacesFrom(dynamic value) {
    if (value is! Iterable) return [];
    return value
        .whereType<Map>()
        .map((place) => Map<String, dynamic>.from(place))
        .toList();
  }

  Future<void> _writePlace({
    required String uid,
    required String name,
    required String address,
    required String type,
    String? placeId,
  }) async {
    final userRef = _userRef(uid);
    final id = placeId ?? _db.collection('users').doc().id;

    await _db.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      if (!userSnapshot.exists) {
        throw StateError('Your user profile could not be found.');
      }

      final places = _savedPlacesFrom(userSnapshot.data()?['savedPlaces']);
      final index = places.indexWhere((place) => place['id'] == id);
      final savedPlace = {
        'id': id,
        'name': name.trim(),
        'address': address.trim(),
        'type': type.trim(),
      };

      if (placeId == null) {
        places.add(savedPlace);
      } else {
        if (index < 0) throw StateError('This saved place no longer exists.');
        places[index] = savedPlace;
      }

      transaction.update(userRef, {'savedPlaces': places});
    });
  }

  Future<void> _deletePlace(String uid, String placeId) async {
    final userRef = _userRef(uid);

    await _db.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      if (!userSnapshot.exists) {
        throw StateError('Your user profile could not be found.');
      }

      final places = _savedPlacesFrom(userSnapshot.data()?['savedPlaces']);
      final originalLength = places.length;
      places.removeWhere((place) => place['id'] == placeId);
      if (places.length == originalLength) {
        throw StateError('This saved place no longer exists.');
      }

      transaction.update(userRef, {'savedPlaces': places});
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openPlaceDialog({
    required String uid,
    String? placeId,
    Map<String, dynamic>? place,
  }) async {
    final nameController = TextEditingController(
      text: (place?['name'] as String?) ?? '',
    );
    final addressController = TextEditingController(
      text: (place?['address'] as String?) ?? '',
    );
    final typeController = TextEditingController(
      text: (place?['type'] as String?) ?? '',
    );
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(placeId == null ? 'Save a Place' : 'Edit Saved Place'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Place name'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a place name'
                      : null,
                ),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter an address'
                      : null,
                ),
                TextFormField(
                  controller: typeController,
                  decoration: const InputDecoration(
                    labelText: 'Category (for example, Home or School)',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a category'
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true) {
      try {
        await _writePlace(
          uid: uid,
          name: nameController.text,
          address: addressController.text,
          type: typeController.text,
          placeId: placeId,
        );
        _showMessage(placeId == null ? 'Place saved.' : 'Place updated.');
      } catch (error) {
        _showMessage('Unable to save place: $error');
      }
    }

    nameController.dispose();
    addressController.dispose();
    typeController.dispose();
  }

  Future<void> _confirmDeletePlace(String uid, String placeId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove saved place?'),
        content: const Text('This place will be removed from your saved list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;

    try {
      await _deletePlace(uid, placeId);
      _showMessage('Place removed.');
    } catch (error) {
      _showMessage('Unable to remove place: $error');
    }
  }

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'school':
        return Icons.school_outlined;
      case 'work':
        return Icons.work_outline;
      case 'home':
        return Icons.home_outlined;
      case 'mall':
        return Icons.store_outlined;
      case 'terminal':
        return Icons.directions_bus_outlined;
      default:
        return Icons.place_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uid = _uid;

    return Scaffold(
      appBar: LookOutAppBar(
        title: 'Saved Places',
        onMenuPressed: widget.onMenuPressed,
      ),
      floatingActionButton: uid == null
          ? null
          : FloatingButton(
              onPressed: () => _openPlaceDialog(uid: uid),
              icon: Icons.add,
              label: 'Save Place',
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
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
                  'Keep frequently visited places in one convenient location.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: uid == null
                ? const Center(
                    child: Text('Sign in to view and manage saved places.'),
                  )
                : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: _userRef(uid).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'Error loading saved places: ${snapshot.error}',
                            ),
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final places = _savedPlacesFrom(
                        snapshot.data?.data()?['savedPlaces'],
                      );
                      if (places.isEmpty) {
                        return const Center(
                          child: Text('No saved places yet. Tap "Save Place".'),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
                        itemCount: places.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final place = places[index];
                          final placeId = place['id'] as String? ?? '';
                          final name = place['name'] as String? ?? 'Place';
                          final address =
                              place['address'] as String? ?? 'No address';
                          final type = place['type'] as String? ?? 'Other';

                          return Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                foregroundColor:
                                    theme.colorScheme.onPrimaryContainer,
                                child: Icon(_iconForType(type)),
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
                              trailing: PopupMenuButton<String>(
                                tooltip: 'Place actions',
                                onSelected: (action) {
                                  if (action == 'edit') {
                                    _openPlaceDialog(
                                      uid: uid,
                                      placeId: placeId,
                                      place: place,
                                    );
                                  } else if (action == 'delete') {
                                    _confirmDeletePlace(uid, placeId);
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
