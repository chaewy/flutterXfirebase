import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  double _zoomLevel = 8; // Initial zoom level

  void _zoomIn() async {
    await controller.setZoom(stepZoom: 2);
  }

  void _zoomOut() async {
    await controller.setZoom(stepZoom: -2);
  }

  final controller = MapController.withUserPosition(
    trackUserLocation: const UserTrackingOption(
      enableTracking: true,
      unFollowUser: false,
    ),
    useExternalTracking: true, // Enable external tracking
  );

  @override
  void dispose() {
    controller.dispose(); // Dispose the controller when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OSM Map'),
      ),
      body: Column(
        children: [
          Expanded(
            child: OSMFlutter(
              controller: controller,
              osmOption: OSMOption(
                zoomOption: ZoomOption(
                  initZoom: _zoomLevel,
                  minZoomLevel: 3,
                  maxZoomLevel: 19,
                  stepZoom: 1.0,
                ),
                showZoomController: true,
                userLocationMarker: UserLocationMaker(
                  personMarker: const MarkerIcon(
                    icon: Icon(
                      Icons.location_history_rounded,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                  directionArrowMarker: const MarkerIcon(
                    icon: Icon(
                      Icons.double_arrow,
                      size: 48,
                    ),
                  ),
                ),
                roadConfiguration: const RoadOption(
                  roadColor: Colors.yellowAccent,
                ),
              ),
              mapIsLoading: Center(child: CircularProgressIndicator()),
              onMapIsReady: (bool isReady) {
                if (isReady) {
                  print("Map is ready");
                  controller.startLocationUpdating(); // Start location updates when the map is ready
                }
              },
              onGeoPointClicked: (geoPoint) async {
                if (geoPoint != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        "Clicked on: ${geoPoint.latitude}, ${geoPoint.longitude}"),
                  ));
                } else {
                  // Handle case where user's location is not available
                }
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: _zoomIn,
              ),
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: _zoomOut,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MapPage(),
  ));
}
