//added poking system ETA and real time PUV tracking - Joshua

//screens
import 'package:final_project_look_out/features/about/about_screen.dart';
import 'package:final_project_look_out/features/analytics/analytics_screen.dart';
import 'package:final_project_look_out/features/announcements/announcements_screen.dart';
import 'package:final_project_look_out/features/commuter_exclusive/rides/rides_screen.dart';
import 'package:final_project_look_out/features/commuter_exclusive/saved/saved_screen.dart';
import 'package:final_project_look_out/features/landing/landing_screen.dart';
import 'package:final_project_look_out/features/profile/profile_screen.dart';
import 'package:final_project_look_out/services/auth_service.dart';
import 'package:final_project_look_out/widgets/confirmation_dialog.dart';

//reusable widgets
import '../../widgets/floating_button.dart';
import '../../widgets/lookout_app_bar.dart';
import '../../widgets/lookout_bottom_nav.dart';
import '../../widgets/lookout_drawer.dart';
import '../../widgets/congestion_map_layers.dart';

//services and packages
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../services/local_bus_tracking_service.dart';
import '../../services/congestion_predictor_service.dart';

//styling
import '../../app/themes/app_colors.dart';
import '../../services/firestore_poke_service.dart';

class CommuterHomeScreen extends StatefulWidget {
  
  const CommuterHomeScreen({super.key});

  @override
  State<CommuterHomeScreen> createState() => _CommuterHomeScreenState();
}

class _CommuterHomeScreenState extends State<CommuterHomeScreen> {
  static const String _allRoutes = '__all_routes__';

  final MapController _mapController = MapController();
  final LocalBusTrackingService _busTracking = LocalBusTrackingService.instance;
  final FirestorePokeService _pokeService = FirestorePokeService.instance;
  String _selectedRoute = _allRoutes;

  // Iloilo City Proper coordinates
  static const LatLng _iloiloCenter = LatLng(10.6969, 122.5644);

  final CongestionPredictorService _predictor = CongestionPredictorService();
  List<CorridorPrediction> _predictions = [];

  // Sample LPTRP route coordinates
  final List<LatLng> _sampleRoutePoints = const [
    LatLng(10.7253, 122.5568),
    LatLng(10.7120, 122.5605),
    LatLng(10.6969, 122.5644),
  ];

  List<String> _routesFrom(List<ActiveBus> buses) {
    final routes = buses
        .where((bus) => bus.isActive)
        .map((bus) => bus.routeName.trim())
        .where((route) => route.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    if (_selectedRoute != _allRoutes && !routes.contains(_selectedRoute)) {
      routes.add(_selectedRoute);
      routes.sort();
    }
    return routes;
  }

  Future<void> _showRouteFilter() async {
    final routes = _routesFrom(_busTracking.activeBuses.value);
    final selectedRoute = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            const ListTile(title: Text('Select route')),
            ListTile(
              leading: Icon(
                _selectedRoute == _allRoutes
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              title: const Text('All routes'),
              onTap: () => Navigator.pop(sheetContext, _allRoutes),
            ),
            for (final route in routes)
              ListTile(
                leading: Icon(
                  _selectedRoute == route
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                title: Text(route),
                onTap: () => Navigator.pop(sheetContext, route),
              ),
          ],
        ),
      ),
    );
    if (!mounted || selectedRoute == null) return;
    setState(() => _selectedRoute = selectedRoute);
  }

  @override
  void initState() {
    super.initState();
    _loadTrafficForecast();
  }

  Future<void> _loadTrafficForecast() async {
    final results = await _predictor.predictAllCorridors();
    if (!mounted) return;
    setState(() => _predictions = results);
  }
  Future<LatLng> _getCommuterPosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ||
        !await Geolocator.isLocationServiceEnabled()) {
      return _iloiloCenter;
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    return LatLng(position.latitude, position.longitude);
  }

  Future<void> _showBusActions(BuildContext context, ActiveBus bus) async {
    final dialogContext = context;
    final position = await _getCommuterPosition();
    if (!mounted) return;
    final eta = await _busTracking.calculateLocalEta(
      commuterPosition: position,
      bus: bus,
    );
    if (!mounted || !dialogContext.mounted) return;
    await showDialog<void>(
      context: dialogContext,
      builder: (dialogContext) => AlertDialog(
        title: Text(bus.plateNumber),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(bus.routeName),
            Text('${bus.speedKmh.toStringAsFixed(1)} km/h'),
            Text('ETA: ${eta.toStringAsFixed(1)} minutes'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showPokeDialog(bus);
            },
            child: const Text('Poke'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPokeDialog(ActiveBus bus) async {
    final messageController = TextEditingController(text: 'Please stop here');
    final position = await _getCommuterPosition();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Poke'),
        content: TextField(controller: messageController),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _pokeService.sendPoke(
                toPlate: bus.plateNumber,
                routeId: bus.routeName,
                location: position,
                message: messageController.text.trim(),
              );
            },
            child: const Text('Send Poke'),
          ),
        ],
      ),
    );
    messageController.dispose();
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
          ? LookOutAppBar(
            title: 'Commuter Dashboard',
            onMenuPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          )
          : null,

      key: _scaffoldKey,
      drawer: LookOutDrawer(
        header: Padding(
          padding: const EdgeInsets.all(16),
          child: Image.asset('assets/images/lookoutBanner.png', height: 60),
        ),
        items: [
           ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen(
                  name: 'Commuter',
                  email: 'commuter@lookout.ph',
                  role: 'commuter',
                )),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.emoji_transportation),
            title: const Text('Rides'),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RidesScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.save),
            title: const Text('Saved'),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SavedScreen()),
              );
            },
          ),

           ListTile(
            leading: const Icon(Icons.announcement),
            title: const Text('Announcements'),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AnnouncementsScreen()),
              );
            },
          ),

           ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Analytics'),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
              );
            },
          ),

           ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => const ConfirmationDialog(
                  title: 'Sign Out',
                  message: 'Are you sure you want to sign out?',
                  confirmText: 'Sign Out',
                ),
              );

              if (confirmed != true || !context.mounted) return;

              Navigator.pop(context);

              await AuthService().signOut();

              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LandingScreen(),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),

      // Bottom Navigation
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
            icon: Icon(Icons.emoji_transportation_outlined),
            selectedIcon: Icon(Icons.emoji_transportation),
            label: 'Rides',
          ),
           NavigationDestination(
            icon: Icon(Icons.save_outlined),
            selectedIcon: Icon(Icons.save),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.announcement_outlined),
            selectedIcon: Icon(Icons.announcement),
            label: 'Announcements',
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
                            .where(
                              (bus) =>
                                  bus.isActive &&
                                  (_selectedRoute == _allRoutes ||
                                      bus.routeName.trim() == _selectedRoute),
                            )
                            .map(
                              (bus) => Marker(
                                point: bus.position,
                                width: 48,
                                height: 48,
                                child: IconButton(
                                  tooltip: bus.plateNumber,
                                  onPressed: () =>
                                      _showBusActions(context, bus),
                                  icon: const Icon(Icons.directions_bus),
                                ),
                              ),
                            )
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

              // Dashboard Information Card
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
                          // Location Icon
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.location_on,
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
                                  'Explore Iloilo City',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'View routes and nearby public vehicles.',
                                  style: theme.textTheme.bodySmall,
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

            RidesScreen(
              onMenuPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            SavedScreen(
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
          ],
        ),
      floatingActionButton: selectedIndex == 0
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'commuter-route-filter',
                  tooltip: _selectedRoute == _allRoutes
                      ? 'Filter routes'
                      : 'Route: $_selectedRoute',
                  onPressed: _showRouteFilter,
                  child: Icon(
                    _selectedRoute == _allRoutes
                        ? Icons.filter_list
                        : Icons.filter_alt,
                  ),
                ),
                const SizedBox(height: 12),
                FloatingButton(
                  heroTag: 'commuter-home-location',
                  onPressed: () {
                    _mapController.move(_iloiloCenter, 15.0);
                  },
                  icon: Icons.my_location,
                ),
              ],
            )
          : null,
    );
  }
}
