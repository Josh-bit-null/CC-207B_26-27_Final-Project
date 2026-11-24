import 'package:final_project_look_out/widgets/floating_button.dart';

import '../../../widgets/lookout_app_bar.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RidesScreen extends StatefulWidget {

  final VoidCallback? onMenuPressed;

  const RidesScreen({
    super.key,
    this.onMenuPressed,
  });

  @override
  State<RidesScreen> createState() => _RidesScreenState();
}

class _RidesScreenState extends State<RidesScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _pokesCol =>
      _db.collection('pokes');
  CollectionReference<Map<String, dynamic>> get _pokeCountsCol =>
      _db.collection('poke_counts');

  String _normalizePlate(String plate) => plate.trim().toUpperCase();

  Future<void> _createRide({
    required String uid,
    required String routeId,
    required String toPlate,
    required String message,
  }) async {
    final userSnapshot = await _usersCol.doc(uid).get();
    final storedName = userSnapshot.data()?['fullName'];
    final fromName = storedName is String && storedName.trim().isNotEmpty
        ? storedName.trim()
        : (_auth.currentUser?.displayName ?? 'Commuter');
    final normalizedPlate = _normalizePlate(toPlate);
    final pokeRef = _pokesCol.doc();
    final countRef = _pokeCountsCol.doc(normalizedPlate);

    await _db.runTransaction((transaction) async {
      final countSnapshot = await transaction.get(countRef);
      final count = (countSnapshot.data()?['count'] as num?)?.toInt() ?? 0;

      transaction.set(pokeRef, {
        'pokeId': pokeRef.id,
        'createdAt': FieldValue.serverTimestamp(),
        'fromName': fromName,
        'fromUid': uid,
        'lat': 10.7202,
        'lng': 122.5621,
        'message': message.trim(),
        'routeId': routeId.trim(),
        'toPlate': normalizedPlate,
      });
      transaction.set(countRef, {
        'count': count + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> _updateRide({
    required String uid,
    required String pokeId,
    required String routeId,
    required String toPlate,
    required String message,
  }) async {
    final pokeRef = _pokesCol.doc(pokeId);
    final normalizedPlate = _normalizePlate(toPlate);

    await _db.runTransaction((transaction) async {
      final pokeSnapshot = await transaction.get(pokeRef);
      if (!pokeSnapshot.exists) {
        throw StateError('This ride no longer exists.');
      }
      if (pokeSnapshot.data()?['fromUid'] != uid) {
        throw StateError('You can only edit your own rides.');
      }

      final oldPlate = _normalizePlate(
        (pokeSnapshot.data()?['toPlate'] as String?) ?? '',
      );
      final plateChanged = oldPlate != normalizedPlate;
      DocumentSnapshot<Map<String, dynamic>>? oldCountSnapshot;
      DocumentSnapshot<Map<String, dynamic>>? newCountSnapshot;
      DocumentReference<Map<String, dynamic>>? oldCountRef;
      DocumentReference<Map<String, dynamic>>? newCountRef;

      if (plateChanged) {
        oldCountRef = _pokeCountsCol.doc(oldPlate);
        newCountRef = _pokeCountsCol.doc(normalizedPlate);
        oldCountSnapshot = await transaction.get(oldCountRef);
        newCountSnapshot = await transaction.get(newCountRef);
      }

      transaction.update(pokeRef, {
        'routeId': routeId.trim(),
        'message': message.trim(),
        'toPlate': normalizedPlate,
      });

      if (plateChanged) {
        final oldCount =
            (oldCountSnapshot!.data()?['count'] as num?)?.toInt() ?? 0;
        final newCount =
            (newCountSnapshot!.data()?['count'] as num?)?.toInt() ?? 0;
        transaction.set(oldCountRef!, {
          'count': oldCount > 0 ? oldCount - 1 : 0,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        transaction.set(newCountRef!, {
          'count': newCount + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    });
  }

  Future<void> _deleteRide(String uid, String pokeId) async {
    final pokeRef = _pokesCol.doc(pokeId);

    await _db.runTransaction((transaction) async {
      final pokeSnapshot = await transaction.get(pokeRef);
      if (!pokeSnapshot.exists) return;
      if (pokeSnapshot.data()?['fromUid'] != uid) {
        throw StateError('You can only delete your own rides.');
      }

      final plate = _normalizePlate(
        (pokeSnapshot.data()?['toPlate'] as String?) ?? '',
      );
      final countRef = _pokeCountsCol.doc(plate);
      final countSnapshot = await transaction.get(countRef);
      final count = (countSnapshot.data()?['count'] as num?)?.toInt() ?? 0;

      transaction.delete(pokeRef);
      transaction.set(countRef, {
        'count': count > 0 ? count - 1 : 0,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openRideDialog({
    required String uid,
    String? pokeId,
    Map<String, dynamic>? ride,
  }) async {
    final routeController = TextEditingController(
      text: (ride?['routeId'] as String?) ?? '',
    );
    final plateController = TextEditingController(
      text: (ride?['toPlate'] as String?) ?? '',
    );
    final messageController = TextEditingController(
      text: (ride?['message'] as String?) ?? '',
    );
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(pokeId == null ? 'Log a Ride' : 'Edit Ride'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: routeController,
                  decoration: const InputDecoration(labelText: 'Route'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a route'
                      : null,
                ),
                TextFormField(
                  controller: plateController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Vehicle plate'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a vehicle plate'
                      : null,
                ),
                TextFormField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message or note',
                  ),
                  maxLines: 2,
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
        if (pokeId == null) {
          await _createRide(
            uid: uid,
            routeId: routeController.text,
            toPlate: plateController.text,
            message: messageController.text,
          );
          _showMessage('Ride saved.');
        } else {
          await _updateRide(
            uid: uid,
            pokeId: pokeId,
            routeId: routeController.text,
            toPlate: plateController.text,
            message: messageController.text,
          );
          _showMessage('Ride updated.');
        }
      } catch (error) {
        _showMessage('Unable to save ride: $error');
      }
    }

    routeController.dispose();
    plateController.dispose();
    messageController.dispose();
  }

  Future<void> _confirmDeleteRide(String pokeId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete ride?'),
        content: const Text('This ride record will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;

    try {
      final uid = _uid;
      if (uid == null) throw StateError('Please sign in again.');
      await _deleteRide(uid, pokeId);
      _showMessage('Ride deleted.');
    } catch (error) {
      _showMessage('Unable to delete ride: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final uid = _uid;

    return Scaffold(
      appBar: LookOutAppBar(
        title: 'My Rides',
        onMenuPressed: widget.onMenuPressed,
      ),
      floatingActionButton: uid == null
          ? null
          : FloatingButton(
              onPressed: () => _openRideDialog(uid: uid),
              icon: Icons.add,
              label: 'Log Ride',
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
                  'Ride History',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your ride and poke records.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: uid == null
                ? const Center(
                    child: Text('Sign in to view and manage your rides.'),
                  )
                : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _pokesCol
                        .where('fromUid', isEqualTo: uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'Error loading rides: ${snapshot.error}',
                            ),
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final rides = [...?snapshot.data?.docs]
                        ..sort((first, second) {
                          final firstTime = first.data()['createdAt'];
                          final secondTime = second.data()['createdAt'];
                          final firstMillis = firstTime is Timestamp
                              ? firstTime.millisecondsSinceEpoch
                              : 0;
                          final secondMillis = secondTime is Timestamp
                              ? secondTime.millisecondsSinceEpoch
                              : 0;
                          return secondMillis.compareTo(firstMillis);
                        });

                      if (rides.isEmpty) {
                        return const Center(
                          child: Text(
                            'No rides yet. Tap "Log Ride" to add one.',
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
                        itemCount: rides.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final ride = rides[index];
                          final data = ride.data();
                          final route =
                              (data['routeId'] as String?) ?? 'Unknown route';
                          final plate = (data['toPlate'] as String?) ?? 'N/A';
                          final message = (data['message'] as String?) ?? '';
                          final createdAt = data['createdAt'];
                          final date = createdAt is Timestamp
                              ? createdAt.toDate().toLocal().toString()
                              : 'Date unavailable';

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.route, color: colors.primary),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          route,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Edit ride',
                                        onPressed: () => _openRideDialog(
                                          uid: uid,
                                          pokeId: ride.id,
                                          ride: data,
                                        ),
                                        icon: const Icon(Icons.edit_outlined),
                                      ),
                                      IconButton(
                                        tooltip: 'Delete ride',
                                        onPressed: () =>
                                            _confirmDeleteRide(ride.id),
                                        icon: const Icon(Icons.delete_outline),
                                      ),
                                    ],
                                  ),
                                  Text(date, style: theme.textTheme.bodySmall),
                                  const SizedBox(height: 4),
                                  Text('Vehicle plate: $plate'),
                                  if (message.trim().isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(message),
                                  ],
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
