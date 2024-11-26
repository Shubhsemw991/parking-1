import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart'; // Location for GPS
import 'package:geocoding/geocoding.dart' as geocoding; // Geocoding with alias
import 'package:url_launcher/url_launcher.dart'; // For launching URL

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({super.key});

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(28.61360707246554, 77.2127014771071),
    zoom: 14,
  );

  final List<Map<String, dynamic>> parkingSpots = [];
  LocationData? _currentLocation;
  final Location _locationService = Location();
  LatLng? _currentLatLng;
  Marker? _currentLocationMarker;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  // Fetch user's current location
  Future<void> _fetchCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _currentLocation = await _locationService.getLocation();
    if (_currentLocation != null) {
      _currentLatLng = LatLng(
        _currentLocation!.latitude!,
        _currentLocation!.longitude!,
      );

      _currentLocationMarker = Marker(
        markerId: const MarkerId('current_location'),
        position: _currentLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Your Current Location'),
      );

      _addNearbyMarkers(_currentLatLng!);

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentLatLng!, zoom: 14),
      ));
    }
  }

  // Add markers and parking spots data
  void _addNearbyMarkers(LatLng currentLocation) {
    parkingSpots.clear();

    // Add parking spots at specified distances
    parkingSpots.add({
      'name': 'Parking Spot 1',
      'position': _getLocationAtDistance(currentLocation, 0.5, bearing: 45),
      'distance': 0.5,
      'image': 'assets/parking1.png',
    });

    parkingSpots.add({
      'name': 'Parking Spot 2',
      'position': _getLocationAtDistance(currentLocation, 1.0, bearing: 90),
      'distance': 1.0,
      'image': 'assets/parking2.png',
    });

    parkingSpots.add({
      'name': 'Parking Spot 3 (750m)',
      'position': _getLocationAtDistance(currentLocation, 0.75, bearing: 135),
      'distance': 0.75,
      'image': 'assets/parking3.png',
    });

    parkingSpots.add({
      'name': 'Parking Spot 4 (600m)',
      'position': _getLocationAtDistance(currentLocation, 0.6, bearing: 180),
      'distance': 0.6,
      'image': 'assets/parking4.png',
    });

    parkingSpots.add({
      'name': 'Parking Spot 5 (800m)',
      'position': _getLocationAtDistance(currentLocation, 0.8, bearing: 225),
      'distance': 0.8,
      'image': 'assets/parking5.png',
    });

    setState(() {});
  }

  // Calculate new coordinates at a given distance and bearing
  LatLng _getLocationAtDistance(LatLng start, double distanceKm, {double bearing = 0}) {
    const double earthRadius = 6371;
    double lat = _degreesToRadians(start.latitude);
    double lon = _degreesToRadians(start.longitude);
    double angularDistance = distanceKm / earthRadius;

    bearing = _degreesToRadians(bearing);

    double newLat = asin(
      sin(lat) * cos(angularDistance) +
          cos(lat) * sin(angularDistance) * cos(bearing),
    );
    double newLon = lon +
        atan2(
          sin(bearing) * sin(angularDistance) * cos(lat),
          cos(angularDistance) - sin(lat) * sin(newLat),
        );

    return LatLng(_radiansToDegrees(newLat), _radiansToDegrees(newLon));
  }

  // Show bottom sheet with parking details
  void _showBottomSheet(String name, LatLng position, double distance, String image) async {
    String detailedPlaceName = await _getDetailedPlaceName(position);

    // Calculate estimated time based on walking speed of 5 km/h
    double walkingSpeedKmH = 5;
    double estimatedTimeMinutes = (distance / walkingSpeedKmH) * 60;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Coordinates: (${position.latitude}, ${position.longitude})",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Distance: ${distance.toStringAsFixed(2)} km",
                  style: const TextStyle(fontSize: 16, color: Colors.blueAccent),
                ),
                const SizedBox(height: 8),
                Text(
                  "Estimated Time to Reach: ${estimatedTimeMinutes.toStringAsFixed(0)} min",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const SizedBox(height: 8),
                Text(
                  "Full Address: $detailedPlaceName",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Image.asset(image, height: 200, width: double.infinity, fit: BoxFit.cover),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _launchGoogleMapsNavigation(position);
                  },
                  child: const Text("Navigate to this Parking Spot"),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingPage(parkingSpotName: name, parkingImage: image),
                      ),
                    );
                  },
                  child: const Text("Book Now"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Fetch detailed place name from latitude and longitude
  Future<String> _getDetailedPlaceName(LatLng position) async {
    try {
      List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      geocoding.Placemark place = placemarks.first;

      return "${place.name}, ${place.subLocality}, ${place.locality}, "
          "${place.administrativeArea}, ${place.postalCode}, ${place.country}";
    } catch (e) {
      return "Unable to fetch location details.";
    }
  }

  // Launch Google Maps with navigation to the parking spot
  Future<void> _launchGoogleMapsNavigation(LatLng destination) async {
    String url = 'google.navigation:q=${destination.latitude},${destination.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180;

  double _radiansToDegrees(double radians) => radians * 180 / pi;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GoogleMap(
                  initialCameraPosition: _initialPosition,
                  mapType: MapType.normal,
                  markers: {
                    if (_currentLocationMarker != null) _currentLocationMarker!,
                    ...parkingSpots.map(
                          (spot) => Marker(
                        markerId: MarkerId(spot['name']),
                        position: spot['position'],
                        infoWindow: InfoWindow(title: spot['name']),
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                      ),
                    )
                  },
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: parkingSpots.length,
                itemBuilder: (context, index) {
                  final spot = parkingSpots[index];
                  return ListTile(
                    title: Text(spot['name']),
                    subtitle: Text("${spot['distance']} km away"),
                    onTap: () {
                      _showBottomSheet(
                        spot['name'],
                        spot['position'],
                        spot['distance'],
                        spot['image'],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingPage extends StatefulWidget {

  final String parkingSpotName;
  final String parkingImage;
  const BookingPage({super.key, required this.parkingSpotName, required this.parkingImage});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? _startTime;
  DateTime? _endTime;
  int _cost = 0;
// Function to initiate the phone call
  Future<void> _makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '9999307157');
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      throw 'Could not make the call';
    }
  }
  // Calculate cost based on selected duration
  void _calculateCost() {
    if (_startTime != null && _endTime != null) {
      final duration = _endTime!.difference(_startTime!);
      if (duration.inMinutes % 30 == 0) {
        _cost = (duration.inMinutes ~/ 30) * 5; // ₹5 per 30 minutes
      } else {
        _cost = ((duration.inMinutes ~/ 30) + 1) * 5;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Book ${widget.parkingSpotName}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Select Booking Time Range for ${widget.parkingSpotName}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _startTime == null
                      ? "Start Time: Not Selected"
                      : "Start Time: ${_startTime!.toLocal()}",
                  style: const TextStyle(fontSize: 16),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final start = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (start != null) {
                      setState(() {
                        _startTime = DateTime.now().copyWith(
                          hour: start.hour,
                          minute: start.minute,
                        );
                        _calculateCost();
                      });
                    }
                  },
                  child: const Text("Start Time"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _endTime == null
                      ? "End Time: Not Selected"
                      : "End Time: ${_endTime!.toLocal()}",
                  style: const TextStyle(fontSize: 16),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final end = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (end != null) {
                      setState(() {
                        _endTime = DateTime.now().copyWith(
                          hour: end.hour,
                          minute: end.minute,
                        );
                        _calculateCost();
                      });
                    }
                  },
                  child: const Text("End Time"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Estimated Cost: ₹$_cost",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Image.asset(widget.parkingImage, height: 200, fit: BoxFit.cover),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _cost > 0 ? () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Booking Confirmed for ${widget.parkingSpotName}"),
                    content: Text("Your booking is confirmed for ₹$_cost."),
                    actions: [

                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context); // Go back to the map
                        },
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              } : null,
              child: const Text("Confirm Booking"),
            ),
            SizedBox(height: 90,),
            IconButton(
              iconSize: 40,
              highlightColor: Colors.blueGrey,
              icon: const Icon(Icons.phone),
              onPressed: _makePhoneCall, // Call function when pressed
            ),

          ],


        ),



      ),


    );
  }
}
