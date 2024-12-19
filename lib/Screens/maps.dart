import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VehicleType {
  final String name;
  final double baseFare;
  final double perKmRate;
  final int eta;

  VehicleType({
    required this.name,
    required this.baseFare,
    required this.perKmRate,
    required this.eta,
  });
}

class CabBookingScreen extends StatefulWidget {
  @override
  _CabBookingScreenState createState() => _CabBookingScreenState();
}

class _CabBookingScreenState extends State<CabBookingScreen> {
  GoogleMapController? mapController;
  TextEditingController destinationController = TextEditingController();
  LatLng? currentPosition;
  LatLng? destinationPosition;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];

  double? distance;
  double? fare;
  VehicleType? selectedVehicleType;

  final String apiKey = 'AIzaSyB8ktFpX6ItlkEAIXk_EPEAiLD_bS0OjFs';
  //Uri apiUri = Uri.parse('AIzaSyB8ktFpX6ItlkEAIXk_EPEAiLD_bS0OjFs');
  Uri apiUri = Uri.https('maps.googleapis.com', '/maps/api/directions/json');
  final List<VehicleType> vehicleTypes = [
    VehicleType(name: 'Mini', baseFare: 50, perKmRate: 12, eta: 3),
    VehicleType(name: 'Sedan', baseFare: 80, perKmRate: 15, eta: 5),
    VehicleType(name: 'SUV', baseFare: 100, perKmRate: 20, eta: 8),
  ];

  @override
  void initState() {
    super.initState();
    selectedVehicleType = vehicleTypes[0];
    _getCurrentLocation();
  }

  // Get user's current location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('Location services are disabled');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showError('Location permissions are permanently denied');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
        _addMarker(
            currentPosition!, 'current', 'Current Location', BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue));
      });

      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentPosition!, zoom: 15),
        ),
      );
    } catch (e) {
      _showError('Error getting current location');
    }
  }

  // Search for destination and add marker
  Future<void> searchDestination(String place) async {
    if (place.isEmpty) return;

    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$place&key=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final location = data['results'][0]['geometry']['location'];
        final destinationLatLng = LatLng(location['lat'], location['lng']);

        setState(() {
          destinationPosition = destinationLatLng;
          _addMarker(destinationLatLng, 'destination', 'Destination',
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));
        });

        await _getPolylinePoints();
        _updateCameraPosition();
      } else {
        _showError('No location found');
      }
    } catch (e) {
      _showError('Error searching for location: $e');
    }
  }

  // Update camera position to include both markers
  void _updateCameraPosition() {
    if (currentPosition != null && destinationPosition != null) {
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          currentPosition!.latitude < destinationPosition!.latitude
              ? currentPosition!.latitude
              : destinationPosition!.latitude,
          currentPosition!.longitude < destinationPosition!.longitude
              ? currentPosition!.longitude
              : destinationPosition!.longitude,
        ),
        northeast: LatLng(
          currentPosition!.latitude > destinationPosition!.latitude
              ? currentPosition!.latitude
              : destinationPosition!.latitude,
          currentPosition!.longitude > destinationPosition!.longitude
              ? currentPosition!.longitude
              : destinationPosition!.longitude,
        ),
      );

      mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    }
  }

  // Get route (polyline points) between current and destination positions
Future<void> _getPolylinePoints() async {
  if (currentPosition == null || destinationPosition == null) {
    _showError('Please ensure location and destination are set');
    return;
  }

  PolylinePoints polylinePoints = PolylinePoints();
  polylineCoordinates.clear();

  try {
    PolylineRequest request = PolylineRequest(
      proxy: apiUri,
      origin: PointLatLng(currentPosition!.latitude, currentPosition!.longitude),
      destination: PointLatLng(destinationPosition!.latitude, destinationPosition!.longitude),
      mode: TravelMode.driving,
    );

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: request,
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      _addPolyline();
      await _calculateDistance();
      _calculateFare();
    } else {
      _showError('No route found.');
    }
  } catch (e) {
    _showError('Error fetching route: $e');
  }
}
  // Add polyline to the map
  void _addPolyline() {
    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          color: Colors.blue,
          points: polylineCoordinates,
          width: 4,
        ),
      );
    });
  }

  // Calculate distance
  Future<void> _calculateDistance() async {
    try {
      double distanceInMeters = await Geolocator.distanceBetween(
        currentPosition!.latitude,
        currentPosition!.longitude,
        destinationPosition!.latitude,
        destinationPosition!.longitude,
      );

      setState(() {
        distance = distanceInMeters / 1000; // Convert to kilometers
      });
    } catch (e) {
      _showError('Error calculating distance');
    }
  }

  // Calculate fare
  void _calculateFare() {
    if (distance == null || selectedVehicleType == null) return;
    setState(() {
      fare = selectedVehicleType!.baseFare + (distance! * selectedVehicleType!.perKmRate);
    });
  }

  // Add marker to the map
  void _addMarker(LatLng position, String id, String title, BitmapDescriptor icon) {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == id);
      _markers.add(
        Marker(
          markerId: MarkerId(id),
          position: position,
          infoWindow: InfoWindow(title: title),
          icon: icon,
        ),
      );
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cab Booking'), backgroundColor: Colors.blue),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: LatLng(0, 0), zoom: 15),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: TextField(
              controller: destinationController,
              decoration: InputDecoration(
                hintText: 'Enter destination',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    searchDestination(destinationController.text);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
