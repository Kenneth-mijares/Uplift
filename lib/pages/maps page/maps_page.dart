import 'package:capstone/pages/maps%20page/coordinates.dart';
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

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        return;
      }
    }

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

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

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Pi / 180
    const r = 6371; // Earth radius in kilometers
    final a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return r * 2 * asin(sqrt(a));
  }

  void _openMap(Map<String, dynamic> coordinate) async {
    final isAvailable = await MapLauncher.isMapAvailable(MapType.google);

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
        title: const Text(
          'Map Coordinates',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 111, 128, 222),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: coordinates.length,
              itemBuilder: (context, index) {
                var coord = coordinates[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 4,
                  child: ListTile(
                    leading: const Icon(Icons.place, color: Color.fromARGB(255, 111, 128, 222)),
                    title: Text(
                      coord['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(
                      'Lat: ${coord['lat']},\nLng: ${coord['lng']}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    onTap: () => _openMap(coord),
                  ),
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
