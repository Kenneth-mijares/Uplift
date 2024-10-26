import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_launcher/map_launcher.dart';
import 'dart:math';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  List<Map<String, dynamic>> coordinates = [
    {'name': 'Place A', 'lat': 37.7749, 'lng': -122.4194},
    {'name': 'Place B', 'lat': 34.0522, 'lng': -118.2437},
    {'name': 'Place C', 'lat': 40.7128, 'lng': -74.0060},
  ];

  Position? _userLocation;
  Map<String, dynamic>? _nearestCoordinate;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

Future<void> _getUserLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return;
  }

  // Check permission status
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
      return;
    }
  }

  // Use LocationSettings instead of deprecated 'desiredAccuracy'
  LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high, // Specify accuracy
    distanceFilter: 100, // Update location only if user moves by 100 meters
  );

  // Get current user location
  Position position = await Geolocator.getCurrentPosition(
    locationSettings: locationSettings,
  );

  setState(() {
    _userLocation = position;
    _nearestCoordinate = _findNearestCoordinate();
  });
}


  Map<String, dynamic>? _findNearestCoordinate() {
    if (_userLocation == null) return null;

    double minDistance = double.infinity;
    Map<String, dynamic>? nearestCoord;

    for (var coord in coordinates) {
      double distance = _calculateDistance(
        _userLocation!.latitude,
        _userLocation!.longitude,
        coord['lat'],
        coord['lng'],
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestCoord = coord;
      }
    }

    return nearestCoord;
  }

  // Haversine formula to calculate distance between two lat/lng points
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Pi / 180
    const r = 6371; // Earth radius in kilometers
    final a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return r * 2 * asin(sqrt(a));
  }

  void _openMap(Map<String, dynamic> coordinate) async {
  final isAvailable = await MapLauncher.isMapAvailable(MapType.google);

  // Check if the value is not null and is true
  if (isAvailable != null && isAvailable) {
    await MapLauncher.showMarker(
      mapType: MapType.google,
      coords: Coords(coordinate['lat'], coordinate['lng']),
      title: coordinate['name'],
    );
  } else {
    print("No map application available.");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Map Coordinates'),
        backgroundColor:  const Color.fromARGB(255, 111, 128, 222),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: coordinates.length,
              itemBuilder: (context, index) {
                var coord = coordinates[index];
                return ListTile(
                  title: Text(coord['name']),
                  subtitle: Text('Lat: ${coord['lat']}, Lng: ${coord['lng']}'),
                  onTap: () => _openMap(coord),
                );
              },
            ),
          ),
          if (_userLocation != null && _nearestCoordinate != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Your Location: (${_userLocation!.latitude}, ${_userLocation!.longitude})'),
                  const SizedBox(height: 10),
                  Text('Nearest Coordinate: ${_nearestCoordinate!['name']}'),
                  ElevatedButton(
                    onPressed: () => _openMap(_nearestCoordinate!),
                    child: const Text('Open Nearest Location in Maps'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
