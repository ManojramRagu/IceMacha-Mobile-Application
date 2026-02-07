import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  // Colombo Branch Coordinates
  static const double shopLatitude = 6.9271;
  static const double shopLongitude = 79.8612;

  Future<double?> getDistanceToShop() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return null;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint(
          'Location permissions are permanently denied, we cannot request permissions.',
        );
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition();
      debugPrint(
        'Current position: ${position.latitude}, ${position.longitude}',
      );

      // Calculate distance in meters
      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        shopLatitude,
        shopLongitude,
      );

      // Convert to kilometers
      return distanceInMeters / 1000;
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }
}
