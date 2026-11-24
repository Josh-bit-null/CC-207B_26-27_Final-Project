//added poking system ETA and real time PUV tracking - Joshua


//screens
import '../about/about_screen.dart';
import '../analytics/analytics_screen.dart';
import '../announcements/announcements_screen.dart';
import '../driver_exclusive/start_ride/start_ride_screen.dart';
import '../driver_exclusive/trips/trips_screen.dart';
import '../driver_exclusive/vehicles/vehicles_screen.dart';
import '../profile/profile_screen.dart';

//reusable widgets
import '../../widgets/floating_button.dart';
import '../../widgets/lookout_app_bar.dart';
import '../../widgets/lookout_bottom_nav.dart';
import '../../widgets/lookout_drawer.dart';
import '../../widgets/congestion_map_layers.dart';

//services and packages
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/local_bus_tracking_service.dart';
import '../../services/firestore_poke_service.dart';
import '../../services/congestion_predictor_service.dart';

//styling
import '../../app/themes/app_colors.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final MapController _mapController = MapController();
  final LocalBusTrackingService _busTracking = LocalBusTrackingService.instance;
  final FirestorePokeService _pokeService = FirestorePokeService.instance;
  String _activePlate = '';
  bool _isRideActive = false;

  // Iloilo City Proper coordinates
  static const LatLng _iloiloCenter = LatLng(10.6969, 122.5644);

  // Sample LPTRP route coordinates
  final List<LatLng> _sampleRoutePoints = const [
    LatLng(10.7253, 122.5568),
    LatLng(10.7120, 122.5605),
    LatLng(10.6969, 122.5644),
  ];

  final CongestionPredictorService _predictor = CongestionPredictorService();
  List<CorridorPrediction> _predictions = [];

  @override
  void initState() {
    super.initState();
    _loadActivePlate();
    _loadTrafficForecast();
  }

  Future<void> _loadTrafficForecast() async {
    final results = await _predictor.predictAllCorridors();
    if (!mounted) return;
    setState(() => _predictions = results);
  }

  Future<void> _loadActivePlate() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (!mounted) return;
    setState(() {
      _activePlate = snapshot.data()?['activePlate'] as String? ?? '';
    });
  }

  Future<void> _toggleRide() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    if (_isRideActive) {
      _busTracking.stopRide(uid);
      setState(() => _isRideActive = false);
      return;
    }
    if (_activePlate.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Active plate is not set.')));
      return;
    }
    await _busTracking.startRide(
      driverId: uid,
      plateNumber: _activePlate,
      routeName: 'Iloilo Route 4',
    );
    setState(() => _isRideActive = true);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey =
    GlobalKey<ScaffoldState>();

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // App Bar
      appBar: selectedIndex == 0
          ? const LookOutAppBar(title: 'Driver Dashboard')
          : null,

      key: _scaffoldKey,
       drawer: LookOutDrawer(
        header: Padding(
          padding: const EdgeInsets.all(16),
          child: Image.asset('assets/images/lookoutBanner.png', height: 60),
        ),
        items: [
          ListTile(
            leading: const Icon(Icons.play_circle),
            title: const Text('Start Ride'),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StartRideScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.route),
            title: const Text('Trips'),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TripsScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.directions_bus),
            title: const Text('Vehicles'),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VehiclesScreen()),
              );
            },
          ),
        ],
      ),

      bottomNavigationBar: LookOutBottomNav(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'About',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.announcement_outlined),
            selectedIcon: Icon(Icons.announcement),
            label: 'Announcement',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),

      // Dashboard Body
      body: IndexedStack(
        index: selectedIndex,
        children: [
          Stack(
            children: [
              // Interactive Map
              FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: _iloiloCenter,
                  initialZoom: 14.0,
                  minZoom: 11.0,
                  maxZoom: 18.0,
                ),
                children: [
                  // 1. Base Map Tiles
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.undeciders.lookout',
                  ),
                  
                  if (_predictions.isNotEmpty) ...[
                    CongestionMapLayers.buildZones(_predictions),
                    CongestionMapLayers.buildPolylines(_predictions),
                    CongestionMapLayers.buildBadges(
                      predictions: _predictions,
                      isDriverView:
                          false, // Set to true in driver_home_screen.dart!
                      onTapCorridor: (corridor) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${corridor.name}: ${corridor.label} '
                              '(${(corridor.confidence * 100).toStringAsFixed(0)}% AI confidence, '
                              'Rain: ${_predictor.currentRainMm} mm)',
                            ),
                          ),
                        );
                      },
                    ),
                  ],

                  // 2. LPTRP Route Polyline
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _sampleRoutePoints,
                        strokeWidth: 4.0,
                        color: AppColor.primaryBlue,
                      ),
                    ],
                  ),

                  // 3. Live PUV Markers
                  ValueListenableBuilder<List<ActiveBus>>(
                    valueListenable: _busTracking.activeBuses,
                    builder: (context, buses, child) {
                      return MarkerLayer(
                        markers: buses
                            .where((bus) => bus.isActive)
                            .map(
                              (bus) => Marker(
                                point: bus.position,
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.directions_bus,
                                  size: 32,
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  if (_activePlate.isNotEmpty)
                    StreamBuilder<
                      List<QueryDocumentSnapshot<Map<String, dynamic>>>
                    >(
                      stream: _pokeService.streamIncomingPokes(_activePlate),
                      builder: (context, snapshot) {
                        final pokes = snapshot.data ?? const [];
                        return MarkerLayer(
                          markers: pokes
                              .map((poke) {
                                final data = poke.data();
                                final lat = data['lat'];
                                final lng = data['lng'];
                                if (lat is! num || lng is! num) return null;
                                return Marker(
                                  point: LatLng(lat.toDouble(), lng.toDouble()),
                                  width: 40,
                                  height: 40,
                                  child: IconButton(
                                    tooltip:
                                        data['message'] as String? ?? 'Poke',
                                    onPressed: () =>
                                        _pokeService.acknowledgePoke(
                                          activePlate: _activePlate,
                                          pokeId: poke.id,
                                        ),
                                    icon: const Icon(Icons.push_pin),
                                  ),
                                );
                              })
                              .whereType<Marker>()
                              .toList(),
                        );
                      },
                    ),

                  // 4. OpenStreetMap Attribution
                  const RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),

              // Driver Information Card
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 3,
                    color: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Route Icon
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.directions_bus,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Information Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Your Route Overview',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'View your route and vehicle position.',
                                  style: theme.textTheme.bodySmall,
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _toggleRide,
                                  child: Text(
                                    _isRideActive ? 'End Ride' : 'Start Ride',
                                  ),
                                ),
                                if (_activePlate.isNotEmpty)
                                  StreamBuilder<int>(
                                    stream: _pokeService.streamPokeCount(
                                      _activePlate,
                                    ),
                                    builder: (context, snapshot) {
                                      final count = snapshot.data ?? 0;
                                      return Row(
                                        children: [
                                          Text('Pokes: $count'),
                                          ElevatedButton(
                                            onPressed: count == 0
                                                ? null
                                                : () => _pokeService
                                                      .clearAllPokesForPlate(
                                                        _activePlate,
                                                      ),
                                            child: const Text('Clear'),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          AboutScreen(
              onMenuPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            AnalyticsScreen(
              onMenuPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            AnnouncementsScreen(
               onMenuPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            ProfileScreen(
              name: 'Commuter', 
              email: 'commuter@lookout.ph', 
              role: 'commmuter',
              onMenuPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
        ],
      ),
      // Floating Location Button
      floatingActionButton: selectedIndex == 0
          ? FloatingButton(
              onPressed: () {
                _mapController.move(_iloiloCenter, 15.0);
              },
              icon: Icons.my_location,
            )
          : null,
    );
  }
}
