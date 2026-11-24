import 'dart:async';

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
  });

  final String driverId;
  final String plateNumber;
  final String routeName;
  final LatLng position;
  final double speedKmh;
  final bool isActive;

  ActiveBus copyWith({LatLng? position, double? speedKmh, bool? isActive}) {
    return ActiveBus(
      driverId: driverId,
      plateNumber: plateNumber,
      routeName: routeName,
      position: position ?? this.position,
      speedKmh: speedKmh ?? this.speedKmh,
      isActive: isActive ?? this.isActive,
    );
  }
}

class LocalBusTrackingService {
  LocalBusTrackingService._();

  static final LocalBusTrackingService instance = LocalBusTrackingService._();

  final ValueNotifier<List<ActiveBus>> activeBuses =
      ValueNotifier<List<ActiveBus>>(<ActiveBus>[]);

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
    stopRide(driverId);

    final initialBus = ActiveBus(
      driverId: driverId,
      plateNumber: plateNumber,
      routeName: routeName,
      position: _waypoints.first,
      speedKmh: 20,
      isActive: true,
    );
    final buses = List<ActiveBus>.from(activeBuses.value)
      ..removeWhere((bus) => bus.driverId == driverId)
      ..add(initialBus);
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
            _updateBus(
              driverId: driverId,
              plateNumber: plateNumber,
              routeName: routeName,
              position: LatLng(position.latitude, position.longitude),
              speedKmh: position.speed > 0 ? position.speed * 3.6 : 20,
            );
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
      _updateBus(
        driverId: driverId,
        plateNumber: plateNumber,
        routeName: routeName,
        position: _waypoints[waypointIndex],
        speedKmh: 20,
      );
    });
  }

  void _updateBus({
    required String driverId,
    required String plateNumber,
    required String routeName,
    required LatLng position,
    required double speedKmh,
  }) {
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
        ),
      );
    }
    activeBuses.value = buses;
  }

  void stopRide(String driverId) {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _simulationTimer?.cancel();
    _simulationTimer = null;
    activeBuses.value = activeBuses.value
        .where((bus) => bus.driverId != driverId)
        .toList();
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
