import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'congestion_predictor_service.dart';

class ActiveBus {
  const ActiveBus({
    required this.driverId,
    required this.plateNumber,
    required this.routeName,
    required this.position,
    required this.speedKmh,
    required this.isActive,
    required this.startedAt,
  });

  final String driverId;
  final String plateNumber;
  final String routeName;
  final LatLng position;
  final double speedKmh;
  final bool isActive;
  final DateTime startedAt;

  ActiveBus copyWith({LatLng? position, double? speedKmh, bool? isActive}) {
    return ActiveBus(
      driverId: driverId,
      plateNumber: plateNumber,
      routeName: routeName,
      position: position ?? this.position,
      speedKmh: speedKmh ?? this.speedKmh,
      isActive: isActive ?? this.isActive,
      startedAt: startedAt,
    );
  }
}

class DriverTrip {
  const DriverTrip({
    required this.driverId,
    required this.plateNumber,
    required this.routeName,
    required this.startedAt,
    required this.endedAt,
  });

  final String driverId;
  final String plateNumber;
  final String routeName;
  final DateTime startedAt;
  final DateTime endedAt;

  Duration get duration => endedAt.difference(startedAt);
}

class LocalBusTrackingService {
  LocalBusTrackingService._();

  static final LocalBusTrackingService instance = LocalBusTrackingService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ValueNotifier<List<ActiveBus>> activeBuses =
      ValueNotifier<List<ActiveBus>>(<ActiveBus>[]);
  final ValueNotifier<List<DriverTrip>> completedTrips =
      ValueNotifier<List<DriverTrip>>(<DriverTrip>[]);
  late final Stream<List<ActiveBus>> remoteActiveBuses = _firestore
      .collection('active_driver_locations')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((document) {
          final data = document.data();
          final latitude = data['latitude'];
          final longitude = data['longitude'];
          final startedAt = data['startedAt'];
          if (latitude is! num || longitude is! num) return null;
          return ActiveBus(
            driverId: document.id,
            plateNumber: data['plateNumber'] as String? ?? '',
            routeName: data['routeName'] as String? ?? '',
            position: LatLng(latitude.toDouble(), longitude.toDouble()),
            speedKmh: (data['speedKmh'] as num?)?.toDouble() ?? 0,
            isActive: true,
            startedAt: startedAt is Timestamp
                ? startedAt.toDate()
                : DateTime.now(),
          );
        }).whereType<ActiveBus>().toList();
      });

  StreamSubscription<Position>? _positionSubscription;
  Timer? _simulationTimer;
  final List<LatLng> _waypoints = const [
    LatLng(10.7495, 122.5432),
    LatLng(10.7258, 122.5572),
    LatLng(10.7138, 122.5635),
    LatLng(10.7030, 122.5665),
  ];

  Future<bool> startRide({
    required String driverId,
    required String plateNumber,
    required String routeName,
  }) async {
    await _stopRide(driverId, recordTrip: false);

    final initialBus = ActiveBus(
      driverId: driverId,
      plateNumber: plateNumber,
      routeName: routeName,
      position: _waypoints.first,
      speedKmh: 20,
      isActive: true,
      startedAt: DateTime.now(),
    );
    final buses = List<ActiveBus>.from(activeBuses.value)
      ..removeWhere((bus) => bus.driverId == driverId)
      ..add(initialBus);
    await _publishBus(initialBus);
    activeBuses.value = buses;

    final canTrack = await _startPositionStream(
      driverId: driverId,
      plateNumber: plateNumber,
      routeName: routeName,
    );
    if (!canTrack) {
      _startWaypointTimer(
        driverId: driverId,
        plateNumber: plateNumber,
        routeName: routeName,
      );
    }
    return true;
  }

  Future<bool> _startPositionStream({
    required String driverId,
    required String plateNumber,
    required String routeName,
  }) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ||
        !await Geolocator.isLocationServiceEnabled()) {
      return false;
    }

    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen(
          (position) {
            unawaited(_updateBus(
              driverId: driverId,
              plateNumber: plateNumber,
              routeName: routeName,
              position: LatLng(position.latitude, position.longitude),
              speedKmh: position.speed > 0 ? position.speed * 3.6 : 20,
            ).catchError((Object error) {
              debugPrint('Unable to publish driver location: $error');
            }));
          },
          onError: (_) {
            _startWaypointTimer(
              driverId: driverId,
              plateNumber: plateNumber,
              routeName: routeName,
            );
          },
        );
    return true;
  }

  void _startWaypointTimer({
    required String driverId,
    required String plateNumber,
    required String routeName,
  }) {
    _simulationTimer?.cancel();
    var waypointIndex = 0;
    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      waypointIndex = (waypointIndex + 1) % _waypoints.length;
      unawaited(_updateBus(
        driverId: driverId,
        plateNumber: plateNumber,
        routeName: routeName,
        position: _waypoints[waypointIndex],
        speedKmh: 20,
      ).catchError((Object error) {
        debugPrint('Unable to publish driver location: $error');
      }));
    });
  }

  Future<void> _updateBus({
    required String driverId,
    required String plateNumber,
    required String routeName,
    required LatLng position,
    required double speedKmh,
  }) async {
    final buses = activeBuses.value.map((bus) {
      if (bus.driverId != driverId) return bus;
      return bus.copyWith(
        position: position,
        speedKmh: speedKmh,
        isActive: true,
      );
    }).toList();
    if (!buses.any((bus) => bus.driverId == driverId)) {
      buses.add(
        ActiveBus(
          driverId: driverId,
          plateNumber: plateNumber,
          routeName: routeName,
          position: position,
          speedKmh: speedKmh,
          isActive: true,
          startedAt: DateTime.now(),
        ),
      );
    }
    activeBuses.value = buses;
    final bus = buses.firstWhere((bus) => bus.driverId == driverId);
    await _publishBus(bus);
  }

  Future<void> stopRide(String driverId) {
    return _stopRide(driverId, recordTrip: true);
  }

  Future<void> _stopRide(String driverId, {required bool recordTrip}) async {
    ActiveBus? activeBus;
    for (final bus in activeBuses.value) {
      if (bus.driverId == driverId) {
        activeBus = bus;
        break;
      }
    }
    if (recordTrip && activeBus != null) {
      completedTrips.value = [
        DriverTrip(
          driverId: activeBus.driverId,
          plateNumber: activeBus.plateNumber,
          routeName: activeBus.routeName,
          startedAt: activeBus.startedAt,
          endedAt: DateTime.now(),
        ),
        ...completedTrips.value,
      ];
    }

    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _simulationTimer?.cancel();
    _simulationTimer = null;
    activeBuses.value = activeBuses.value
        .where((bus) => bus.driverId != driverId)
        .toList();
    await _firestore
        .collection('active_driver_locations')
        .doc(driverId)
        .delete();
  }

  Future<void> _publishBus(ActiveBus bus) {
    return _firestore
        .collection('active_driver_locations')
        .doc(bus.driverId)
        .set({
          'driverId': bus.driverId,
          'plateNumber': bus.plateNumber,
          'routeName': bus.routeName,
          'latitude': bus.position.latitude,
          'longitude': bus.position.longitude,
          'speedKmh': bus.speedKmh,
          'startedAt': Timestamp.fromDate(bus.startedAt),
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<double> calculateLocalEta({
    required LatLng commuterPosition,
    required ActiveBus bus,
  }) async {
    final distanceMeters = const Distance().as(
      LengthUnit.Meter,
      commuterPosition,
      bus.position,
    );
    final travelDistanceKm = (distanceMeters * 1.28) / 1000;
    final speedKmh = bus.speedKmh > 0 ? bus.speedKmh : 20;
    var etaMins = (travelDistanceKm / speedKmh) * 60;

    final predictions = await CongestionPredictorService()
        .predictAllCorridors();
    for (final prediction in predictions) {
      final distanceToCorridor = const Distance().as(
        LengthUnit.Meter,
        bus.position,
        prediction.center,
      );
      if (distanceToCorridor <= 1500) {
        etaMins += prediction.extraDelayMins;
        break;
      }
    }
    return etaMins;
  }
}
