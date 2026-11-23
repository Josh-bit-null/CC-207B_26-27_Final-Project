import 'package:final_project_look_out/features/about/about_screen.dart';
import 'package:final_project_look_out/features/analytics/analytics_screen.dart';
import 'package:final_project_look_out/features/announcements/announcements_screen.dart';
import 'package:final_project_look_out/features/commuter_exclusive/rides/rides_screen.dart';
import 'package:final_project_look_out/features/commuter_exclusive/saved/saved_screen.dart';
import 'package:final_project_look_out/features/profile/profile_screen.dart';
import 'package:final_project_look_out/widgets/floating_button.dart';
import 'package:final_project_look_out/widgets/lookout_app_bar.dart';
import 'package:final_project_look_out/widgets/lookout_bottom_nav.dart';
import 'package:final_project_look_out/widgets/lookout_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../app/themes/app_colors.dart';

class CommuterHomeScreen extends StatefulWidget {
  
  const CommuterHomeScreen({super.key});

  @override
  State<CommuterHomeScreen> createState() =>
      _CommuterHomeScreenState();
}

class _CommuterHomeScreenState
    extends State<CommuterHomeScreen> {
  final MapController _mapController = MapController();

  // Iloilo City Proper coordinates
  static const LatLng _iloiloCenter = LatLng(
    10.6969,
    122.5644,
  );

  // Sample LPTRP route coordinates
  final List<LatLng> _sampleRoutePoints = const [
    LatLng(10.7253, 122.5568),
    LatLng(10.7120, 122.5605),
    LatLng(10.6969, 122.5644),
  ];

  // Sample live PUV coordinates
  // Update this list using the Socket.io stream.
  final List<LatLng> _livePuvLocations = const [
    LatLng(10.7120, 122.5605),
  ];

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
      ? const LookOutAppBar(
        title: 'Commuter Dashboard',
      )
      : null,

      key: _scaffoldKey,
      drawer: LookOutDrawer(
        header: Padding(
          padding: const EdgeInsets.all(16),
          child: Image.asset(
            'assets/images/lookoutBanner.png',
            height: 60,
          ),
        ),
        items: [
          ListTile(
            leading: const Icon(Icons.emoji_transportation),
            title: const Text('Rides'),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RidesScreen(),
                ),
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
                MaterialPageRoute(
                  builder: (context) => const SavedScreen(),
                ),
              );
            },
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: LookOutBottomNav(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index){
          setState(() {
            selectedIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home), 
            label: 'Home'
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info), 
            label: 'About'
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics), 
            label: 'Analytics'
          ),
          NavigationDestination(
            icon: Icon(Icons.announcement_outlined),
            selectedIcon: Icon(Icons.announcement), 
            label: 'Announcement'
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person), 
            label: 'Profile'
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
                      userAgentPackageName:
                          'com.undeciders.lookout',
                    ),

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
                    MarkerLayer(
                      markers: _livePuvLocations.map((coords) {
                        return Marker(
                          point: coords,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.directions_bus,
                            color: AppColor.successGreen,
                            size: 32,
                          ),
                        );
                      }).toList(),
                    ),

                    // 4. OpenStreetMap Attribution
                    const RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                        ),
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
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Explore Iloilo City',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
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