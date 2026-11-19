import 'package:final_project_look_out/widgets/floating_button.dart';
import 'package:final_project_look_out/widgets/lookout_app_bar.dart';
import 'package:final_project_look_out/widgets/lookout_bottom_nav.dart';
import 'package:final_project_look_out/widgets/lookout_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CommuterHomeScreen extends StatefulWidget {
  const CommuterHomeScreen({super.key});

  @override
  State<CommuterHomeScreen> createState() => _CommuterHomeScreenState();
}

class _CommuterHomeScreenState extends State<CommuterHomeScreen> {

  @override
  void initState() {
    super.initState();
  }
final MapController _mapController = MapController();

  // Iloilo City Proper coordinates, I just got this from internet
  static const LatLng _iloiloCenter = LatLng(10.6969, 122.5644);

  // Sample LPTRP route coordinates (like the Jaro Plaza to City Proper), this also
  final List<LatLng> _sampleRoutePoints = const [
    LatLng(10.7253, 122.5568),
    LatLng(10.7120, 122.5605),
    LatLng(10.6969, 122.5644),
  ];

  // Live PUV coordinates (update this list from my Socket.io stream)
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
    return Scaffold(
      //You can add here at the top jessa, the app bar and drawer and bottom nav
      appBar: const LookOutAppBar(
        title: 'Commuter Dashboard', //replace with the actual title.
      ),

      drawer: const LookOutDrawer(
        header: SizedBox.shrink(),
        items: [],
      ),

      bottomNavigationBar: const LookOutBottomNav(),

      body: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: _iloiloCenter,
          initialZoom: 14.0,
          minZoom: 11.0,
          maxZoom: 18.0,
        ),
        children: [
          // 1. Base map tiles (OpenStreetMap)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.undeciders.lookout',
          ),

          // 2. LPTRP Route Polyline
          PolylineLayer(
            polylines: [
              Polyline(
                points: _sampleRoutePoints,
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          ),

          // 3. Live E-Bus / Jeepney Markers
          MarkerLayer(
            markers: _livePuvLocations.map((coords) {
              return Marker(
                point: coords,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.directions_bus,
                  color: Colors.red,
                  size: 32,
                ),
              );
            }).toList(),
          ),

          // 4. Required OSM attribution
          const RichAttributionWidget(
            attributions: [
              TextSourceAttribution('OpenStreetMap contributors'),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingButton(
        onPressed: () => _mapController.move(_iloiloCenter, 15.0),
        icon: Icons.my_location,
      ),
    );
  }
}