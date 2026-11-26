import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_look_out/widgets/confirmation_dialog.dart';
import 'package:final_project_look_out/widgets/loader.dart';
import 'package:final_project_look_out/widgets/popup_notif.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../services/local_bus_tracking_service.dart';
import '../../../widgets/floating_button.dart';
import '../../../widgets/lookout_app_bar.dart';

class _RideTrackingViewState {
  const _RideTrackingViewState({this.message, this.nearbyPlate});

  final String? message;
  final String? nearbyPlate;
}

class _CommuterRideTracker {
  _CommuterRideTracker._();

  static final _CommuterRideTracker instance = _CommuterRideTracker._();

  static const double _vehicleLengthMeters = 8.7;
  static const double _vehicleWidthMeters = 2.3;
  static const double _fallbackRadiusMeters = 9.0;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalBusTrackingService _busTracking = LocalBusTrackingService.instance;
  final Distance _distance = const Distance();
  final ValueNotifier<_RideTrackingViewState> viewState = ValueNotifier(
    const _RideTrackingViewState(),
  );
  final Map<String, LatLng> _previousBusPositions = {};
  final Map<String, double> _busHeadings = {};

  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<List<ActiveBus>>? _remoteBusSubscription;
  StreamSubscription<User?>? _authSubscription;
  Future<void>? _startFuture;
  LatLng? _commuterPosition;
  List<ActiveBus> _remoteBuses = [];
  String? _uid;
  bool _busListenerAttached = false;
  bool _updatingSession = false;
  bool _updateRequested = false;
  bool _locationStartupInProgress = false;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _db.collection('users').doc(uid);

  Future<void> ensureStarted(String? uid) async {
    if (uid == null) return;
    if (_uid == uid) {
      final starting = _startFuture;
      if (starting != null) {
        await starting;
      } else {
        await _startLocationTracking();
      }
      return;
    }

    await _switchUser(uid);
  }

  Future<void> _switchUser(String? uid) async {
    await _stopTracking();
    _uid = uid;
    if (uid == null) return;

    _busTracking.activeBuses.addListener(_onBusesChanged);
    _busListenerAttached = true;
    _remoteBusSubscription = _busTracking.remoteActiveBuses.listen(
      (buses) {
        _remoteBuses = buses;
        _onBusesChanged();
      },
      onError: (Object error) {
        _setMessage('Unable to load driver locations: $error');
      },
    );
    _observeBusPositions(_trackedBuses);
    _authSubscription ??= _auth.authStateChanges().listen(
      _onAuthChanged,
      onError: (Object error) =>
          _setMessage('Authentication tracking failed: $error'),
    );

    final startFuture = _startLocationTracking();
    _startFuture = startFuture;
    try {
      await startFuture;
    } finally {
      if (identical(_startFuture, startFuture)) _startFuture = null;
    }
  }

  void _onAuthChanged(User? user) {
    if (user?.uid == _uid) return;
    unawaited(_switchUser(user?.uid));
  }

  Future<void> _stopTracking() async {
    if (_busListenerAttached) {
      _busTracking.activeBuses.removeListener(_onBusesChanged);
      _busListenerAttached = false;
    }
    await _remoteBusSubscription?.cancel();
    _remoteBusSubscription = null;
    _remoteBuses = [];
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _commuterPosition = null;
    _previousBusPositions.clear();
    _busHeadings.clear();
    _updatingSession = false;
    _updateRequested = false;
    _setViewState(const _RideTrackingViewState());
  }

  Future<void> _startLocationTracking() async {
    if (_locationStartupInProgress || _uid == null) return;
    _locationStartupInProgress = true;
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _setMessage('Allow location access to detect nearby PUVs.');
        return;
      }
      if (!await Geolocator.isLocationServiceEnabled()) {
        _setMessage('Turn on location services to detect nearby PUVs.');
        return;
      }

      await _refreshLocation();
      _positionSubscription ??=
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 2,
            ),
          ).listen(
            (position) {
              _commuterPosition = LatLng(position.latitude, position.longitude);
              unawaited(_updateRideSession());
            },
            onError: (Object error) {
              _setMessage('Location tracking failed: $error');
            },
          );
    } catch (error) {
      _setMessage('Unable to access your location: $error');
    } finally {
      _locationStartupInProgress = false;
    }
  }

  Future<bool> refreshLocation() async {
    await _startLocationTracking();
    final state = viewState.value;
    return state.message == null && state.nearbyPlate != null;
  }

  Future<void> _refreshLocation() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    _commuterPosition = LatLng(position.latitude, position.longitude);
    _setMessage(null);
    await _updateRideSession();
  }

  void _setMessage(String? message) {
    _setViewState(
      _RideTrackingViewState(
        message: message,
        nearbyPlate: viewState.value.nearbyPlate,
      ),
    );
  }

  void _setViewState(_RideTrackingViewState state) {
    viewState.value = state;
  }

  void _onBusesChanged() {
    _observeBusPositions(_trackedBuses);
    unawaited(_updateRideSession());
  }

  List<ActiveBus> get _trackedBuses {
    final busesByDriver = {for (final bus in _remoteBuses) bus.driverId: bus};
    for (final bus in _busTracking.activeBuses.value) {
      busesByDriver[bus.driverId] = bus;
    }
    return busesByDriver.values.toList();
  }

  void _observeBusPositions(List<ActiveBus> buses) {
    final activeDriverIds = buses
        .where((bus) => bus.isActive)
        .map((bus) => bus.driverId)
        .toSet();
    _previousBusPositions.removeWhere(
      (driverId, _) => !activeDriverIds.contains(driverId),
    );
    _busHeadings.removeWhere(
      (driverId, _) => !activeDriverIds.contains(driverId),
    );

    for (final bus in buses.where((bus) => bus.isActive)) {
      final previous = _previousBusPositions[bus.driverId];
      if (previous != null &&
          _distance.as(LengthUnit.Meter, previous, bus.position) > 0.5) {
        _busHeadings[bus.driverId] = _bearingBetween(previous, bus.position);
      }
      _previousBusPositions[bus.driverId] = bus.position;
    }
  }

  double _bearingBetween(LatLng from, LatLng to) {
    final lat1 = from.latitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final deltaLng = (to.longitude - from.longitude) * math.pi / 180;
    final y = math.sin(deltaLng) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(deltaLng);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  bool _isInsideVehicleFootprint(ActiveBus bus, LatLng commuterPosition) {
    final heading = _busHeadings[bus.driverId];
    final distance = _distance.as(
      LengthUnit.Meter,
      bus.position,
      commuterPosition,
    );
    if (heading == null) return distance <= _fallbackRadiusMeters;

    final bearing = _bearingBetween(bus.position, commuterPosition);
    final relativeBearing = (bearing - heading) * math.pi / 180;
    final alongVehicle = distance * math.cos(relativeBearing);
    final acrossVehicle = distance * math.sin(relativeBearing);
    return alongVehicle.abs() <= _vehicleLengthMeters / 2 &&
        acrossVehicle.abs() <= _vehicleWidthMeters / 2;
  }

  Future<void> _updateRideSession() async {
    final uid = _uid;
    final position = _commuterPosition;
    if (uid == null || position == null) return;
    if (_updatingSession) {
      _updateRequested = true;
      return;
    }

    final nearbyBuses =
        _trackedBuses
            .where(
              (bus) => bus.isActive && _isInsideVehicleFootprint(bus, position),
            )
            .toList()
          ..sort(
            (first, second) => _distance
                .as(LengthUnit.Meter, position, first.position)
                .compareTo(
                  _distance.as(LengthUnit.Meter, position, second.position),
                ),
          );
    final nearbyBus = nearbyBuses.isEmpty ? null : nearbyBuses.first;
    _setViewState(
      _RideTrackingViewState(
        message: viewState.value.message,
        nearbyPlate: nearbyBus?.plateNumber,
      ),
    );

    _updatingSession = true;
    try {
      final userRef = _userRef(uid);
      await _db.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userRef);
        if (!userSnapshot.exists) {
          throw StateError('Your user profile could not be found.');
        }

        final userData = userSnapshot.data()!;
        final activeSessionValue = userData['activeRideSession'];
        final activeSession = activeSessionValue is Map
            ? Map<String, dynamic>.from(activeSessionValue)
            : null;
        if (nearbyBus == null && activeSession == null) return;
        if (nearbyBus != null &&
            activeSession?['driverId'] == nearbyBus.driverId) {
          return;
        }

        final updates = <String, dynamic>{};
        if (activeSession != null) {
          final endedAt = Timestamp.now();
          final startedAt = activeSession['startedAt'];
          final startedDate = startedAt is Timestamp
              ? startedAt.toDate()
              : endedAt.toDate();
          final rideId = activeSession['rideId'];
          final rideRef = rideId is String && rideId.isNotEmpty
              ? _db.collection('rides').doc(rideId)
              : _db.collection('rides').doc();
          transaction.set(rideRef, {
            'id': rideRef.id,
            'commuterUid': uid,
            'driverId': activeSession['driverId'],
            'toPlate': activeSession['toPlate'],
            'routeId': activeSession['routeId'],
            'startedAt': startedAt,
            'endedAt': endedAt,
            'durationSeconds': endedAt
                .toDate()
                .difference(startedDate)
                .inSeconds,
            'status': 'completed',
          });
        }

        if (nearbyBus == null) {
          updates['activeRideSession'] = FieldValue.delete();
        } else {
          updates['activeRideSession'] = {
            'rideId': _db.collection('rides').doc().id,
            'driverId': nearbyBus.driverId,
            'toPlate': nearbyBus.plateNumber,
            'routeId': nearbyBus.routeName,
            'startedAt': Timestamp.now(),
          };
        }
        transaction.update(userRef, updates);
      });
    } catch (error) {
      _setMessage('Unable to update ride history: $error');
    } finally {
      _updatingSession = false;
      if (_updateRequested) {
        _updateRequested = false;
        unawaited(_updateRideSession());
      }
    }
  }
}

class RidesScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;
  final Future<void> Function()? onShowMap;

  const RidesScreen({super.key, this.onMenuPressed, this.onShowMap});

  @override
  State<RidesScreen> createState() => _RidesScreenState();
}

class _RidesScreenState extends State<RidesScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _tracker = _CommuterRideTracker.instance;

  String? get _uid => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _db.collection('users').doc(uid);

  List<Map<String, dynamic>> _recordsFrom(dynamic value) {
    if (value is! Iterable) return [];
    return value
        .whereType<Map>()
        .map((record) => Map<String, dynamic>.from(record))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _tracker.viewState.addListener(_onTrackerStateChanged);
    unawaited(_tracker.ensureStarted(_uid));
  }

  @override
  void dispose() {
    _tracker.viewState.removeListener(_onTrackerStateChanged);
    super.dispose();
  }

  void _onTrackerStateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _checkNearbyPuv() async {
    final foundPuv = await _tracker.refreshLocation();
    if (!mounted) return;
    if (!foundPuv) {
      if (_tracker.viewState.value.message == null) {
        _showMessage('No active PUV detected nearby.', 'Info', NotifType.info);
      }
      return;
    }

    final onShowMap = widget.onShowMap;
    if (onShowMap != null) {
      await onShowMap();
    } else {
      await Navigator.of(context).maybePop();
    }
  }

  Future<void> _toggleFavorite(
    String uid,
    Map<String, dynamic> ride,
    bool isFavorite,
  ) async {
    final userRef = _userRef(uid);
    final rideId = ride['id'] as String?;
    if (rideId == null || rideId.isEmpty) return;

    try {
      await _db.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userRef);
        if (!userSnapshot.exists) {
          throw StateError('Your user profile could not be found.');
        }
        final savedRides = _recordsFrom(userSnapshot.data()?['savedRides']);
        savedRides.removeWhere((saved) => saved['rideId'] == rideId);
        if (!isFavorite) {
          savedRides.add({
            'rideId': rideId,
            'driverId': ride['driverId'],
            'toPlate': ride['toPlate'],
            'routeId': ride['routeId'],
            'startedAt': ride['startedAt'],
            'endedAt': ride['endedAt'],
            'durationSeconds': ride['durationSeconds'],
            'status': ride['status'],
          });
        }
        transaction.update(userRef, {'savedRides': savedRides});
      });
      _showMessage(isFavorite ? 'Ride removed from favorites.' : 'Ride saved.', 'Info', NotifType.info);
    } catch (error) {
      _showMessage('Unable to update favorites: $error', 'Error', NotifType.error);
    }
  }

  Future<void> _deleteRide(String uid, String rideId) async {
    final rideRef = _db.collection('rides').doc(rideId);
    try {
      await _db.runTransaction((transaction) async {
        final rideSnapshot = await transaction.get(rideRef);
        if (!rideSnapshot.exists) return;
        if (rideSnapshot.data()?['commuterUid'] != uid) {
          throw StateError('You can only delete your own rides.');
        }
        transaction.delete(rideRef);
      });
      _showMessage('Ride deleted.','Info', NotifType.info);
    } catch (error) {
      _showMessage('Unable to delete ride: $error', 'Error', NotifType.error);
    }
  }

  Future<void> _confirmDeleteRide(String uid, String rideId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => ConfirmationDialog(
        title: 'Delete ride?',
        content: 'This recent ride will be permanently removed.',
        confirmText: 'Delete',
      ),
    );
    if (shouldDelete == true) await _deleteRide(uid, rideId);
  }

  Future<void> _showRideDetails(
    BuildContext context,
    Map<String, dynamic> ride,
  ) async {
    final startedAt = _formatDate(ride['startedAt']);
    final endedAt = _formatDate(ride['endedAt']);
    final durationSeconds = ride['durationSeconds'] as int? ?? 0;
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ride Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Route: ${ride['routeId'] ?? 'Unknown route'}'),
            const SizedBox(height: 8),
            Text('Vehicle: ${ride['toPlate'] ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Started: $startedAt'),
            const SizedBox(height: 8),
            Text('Ended: $endedAt'),
            const SizedBox(height: 8),
            Text('Duration: ${minutes}m ${seconds}s'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic value) {
    if (value is! Timestamp) return 'Unavailable';
    return value.toDate().toLocal().toString();
  }

  void _showMessage(String message, String title, NotifType type) {
    if (!mounted) return;
    PopupNotif(message: message, title: title, type: type,).show(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uid = _uid;

    return Scaffold(
      appBar: LookOutAppBar(
        title: 'Recent Rides',
        onMenuPressed: widget.onMenuPressed,
      ),
      floatingActionButton: uid == null
          ? null
          : FloatingButton(
              heroTag: 'rides-check-nearby-puv',
              onPressed: _checkNearbyPuv,
              icon: Icons.my_location,
              label: 'Check Nearby PUV',
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
                  'Recent Rides',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (_tracker.viewState.value.message != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _tracker.viewState.value.message!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ] else if (_tracker.viewState.value.nearbyPlate != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Ride in progress near PUV '
                    '${_tracker.viewState.value.nearbyPlate}',
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: uid == null
                ? const Center(
                    child: Text('Sign in to view your recent rides.'),
                  )
                : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: _userRef(uid).snapshots(),
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
                        return const Loader.circular();
                      }

                      final favoriteIds = _recordsFrom(
                        snapshot.data?.data()?['savedRides'],
                      ).map((ride) => ride['rideId']).toSet();
                      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _db
                            .collection('rides')
                            .where('commuterUid', isEqualTo: uid)
                            .snapshots(),
                        builder: (context, ridesSnapshot) {
                          if (ridesSnapshot.hasError) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  'Error loading rides: ${ridesSnapshot.error}',
                                ),
                              ),
                            );
                          }
                          if (ridesSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Loader.circular();
                          }

                          final rides =
                              ridesSnapshot.data?.docs
                                  .map(
                                    (document) => {
                                      'id': document.id,
                                      ...document.data(),
                                    },
                                  )
                                  .toList() ??
                              <Map<String, dynamic>>[];
                          rides.sort((first, second) {
                            final firstTime = first['endedAt'];
                            final secondTime = second['endedAt'];
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
                                'No recent rides yet. Stay near an active PUV, then leave its detection area.',
                                textAlign: TextAlign.center,
                              ),
                            );
                          }

                          return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
                        itemCount: rides.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final ride = rides[index];
                          final rideId = ride['id'] as String? ?? '';
                          final isFavorite = favoriteIds.contains(rideId);
                          final route =
                              ride['routeId'] as String? ?? 'Unknown route';
                          final plate = ride['toPlate'] as String? ?? 'N/A';

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.route,
                                        color: theme.colorScheme.primary,
                                      ),
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
                                        tooltip: isFavorite
                                            ? 'Unfavorite ride'
                                            : 'Favorite ride',
                                        onPressed: () => _toggleFavorite(
                                          uid,
                                          ride,
                                          isFavorite,
                                        ),
                                        icon: Icon(
                                          isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Delete ride',
                                        onPressed: () =>
                                            _confirmDeleteRide(uid, rideId),
                                        icon: const Icon(Icons.delete_outline),
                                      ),
                                    ],
                                  ),
                                  Text('Vehicle: $plate'),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Ended: ${_formatDate(ride['endedAt'])}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () =>
                                          _showRideDetails(context, ride),
                                      child: const Text('See More'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                            },
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
