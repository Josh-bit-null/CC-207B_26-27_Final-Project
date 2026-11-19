import 'package:final_project_look_out/widgets/floating_button.dart';
import 'package:final_project_look_out/widgets/lookout_app_bar.dart';
import 'package:final_project_look_out/widgets/lookout_bottom_nav.dart';
import 'package:final_project_look_out/widgets/lookout_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../app/themes/app_colors.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() =>
      _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
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

  // Sample PUV coordinates
  // Update this list using the Socket.io stream.
  final List<LatLng> _livePuvLocations = const [
    LatLng(10.7120, 122.5605),
  ];

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // App Bar
      appBar: const LookOutAppBar(
        title: 'Driver Dashboard',
      ),

      // Drawer
      drawer: const LookOutDrawer(
        header: SizedBox.shrink(),
        items: [],
      ),

      // Bottom Navigation
      bottomNavigationBar: const LookOutBottomNav(),

      // Dashboard Body
      body: Stack(
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
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Your Route Overview',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'View your route and vehicle position.',
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

      // Floating Location Button
      floatingActionButton: FloatingButton(
        onPressed: () {
          _mapController.move(_iloiloCenter, 15.0);
        },
        icon: Icons.my_location,
      ),
    );
  }
}
