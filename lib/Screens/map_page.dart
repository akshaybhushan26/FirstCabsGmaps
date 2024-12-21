import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  final String startPoint;
  final String endPoint;

  const MapPage({required this.startPoint, required this.endPoint, Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> _polylineCoordinates = [];
  double? estimatedFare;

  @override
  void initState() {
    super.initState();
    _getDirections();
  }

  Future<void> _getDirections() async {
    try {
      // Get the LatLng for start and end points using Geocoding API
      LatLng startLatLng = await _getLatLngFromAddress(widget.startPoint);
      LatLng endLatLng = await _getLatLngFromAddress(widget.endPoint);

      // Add markers for start and end points
      setState(() {
        _markers.add(Marker(markerId: MarkerId('start'), position: startLatLng));
        _markers.add(Marker(markerId: MarkerId('end'), position: endLatLng));
      });

      // Fetch the route using Directions API
      _fetchRoute(startLatLng, endLatLng);

      // Estimate fare (example: assume ₹10 per km)
      double distanceInKm = Geolocator.distanceBetween(
            startLatLng.latitude,
            startLatLng.longitude,
            endLatLng.latitude,
            endLatLng.longitude,
          ) /
          1000;
      setState(() {
        estimatedFare = distanceInKm * 10; // Example calculation
      });
    } catch (e) {
      print('Error getting directions: $e');
    }
  }

  Future<LatLng> _getLatLngFromAddress(String address) async {
    // Use Geocoding API to convert an address to LatLng
    // Replace with your Geocoding API code (or use a package)
    // Here’s an example response:
    if (address.toLowerCase().contains('indira gandhi')) {
      return LatLng(28.5562, 77.1000);
    } else if (address.toLowerCase().contains('rohini')) {
      return LatLng(28.7362, 77.1234);
    }
    // Use real API or package to fetch LatLng
    return LatLng(28.7041, 77.1025); // Default for Delhi
  }

  Future<void> _fetchRoute(LatLng start, LatLng end) async {
    // Fetch the route using Directions API or Polyline Points package
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyB8ktFpX6ItlkEAIXk_EPEAiLD_bS0OjFs',
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(end.latitude, end.longitude),
    );

    if (result.status == 'OK') {
    print('Route Points: ${result.points}');
    setState(() {
      _polylineCoordinates =
          result.points.map((point) => LatLng(point.latitude, point.longitude)).toList();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue,
          width: 5,
          points: _polylineCoordinates,
        ),
      );
    });
  } else {
    print('Error fetching route: ${result.errorMessage}');
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(28.7041, 77.1025), // Default to Delhi
              zoom: 10,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
          ),
          if (estimatedFare != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  'Estimated Fare: ₹${estimatedFare?.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
