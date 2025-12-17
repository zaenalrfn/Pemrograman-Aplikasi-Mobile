import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:math' show cos, sqrt, asin, sin, pi;

import '../models/attendance_location_model.dart';

class GeofenceService {
  // 🔹 Cek apakah layanan lokasi aktif
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // 🔹 Cek dan minta izin lokasi
  static Future<LocationPermission> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationPermission.denied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermission.deniedForever;
    }

    return permission;
  }

  // 🔹 Ambil posisi sekarang
  static Future<Position?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await checkAndRequestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy:
            LocationAccuracy.bestForNavigation, // High accuracy needed
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  // 🔹 Fetch Locations from API
  static Future<List<AttendanceLocationModel>> _fetchLocations() async {
    try {
      final baseUrl = dotenv.env['API_URL'];
      final url = Uri.parse('$baseUrl/attendance-locations');

      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => AttendanceLocationModel.fromJson(json))
            .toList();
      } else {
        debugPrint("Failed to fetch locations: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("Exception fetching locations: $e");
      return [];
    }
  }

  // 🔹 Hitung jarak antar dua koordinat (pakai Haversine formula)
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // meter
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  static double _toRadians(double degree) {
    return degree * (pi / 180.0);
  }

  // 🔹 Cek apakah user berada dalam area SALAH SATU lokasi
  static Future<GeofenceResult> isWithinAllowedArea() async {
    Position? position = await getCurrentPosition();

    if (position == null) {
      return GeofenceResult(
        isAllowed: false,
        message:
            'Tidak dapat mengakses lokasi. Pastikan GPS aktif dan izin lokasi diberikan.',
        distance: null,
      );
    }

    // 1. Fetch Locations Dynamically
    List<AttendanceLocationModel> locations = await _fetchLocations();

    if (locations.isEmpty) {
      // Fallback or Error if no locations found
      return GeofenceResult(
        isAllowed: false,
        message: 'Gagal mengambil data lokasi absensi dari server.',
        distance: null,
      );
    }

    AttendanceLocationModel? closestLocation;
    double minDistance = double.infinity;
    AttendanceLocationModel? matchedLocation;

    // 2. Iterate to find if inside ANY location
    for (var loc in locations) {
      double dist = calculateDistance(
        position.latitude,
        position.longitude,
        loc.latitude,
        loc.longitude,
      );

      if (dist <= loc.radiusMeters) {
        matchedLocation = loc;
        closestLocation = loc;
        minDistance = dist;
        break; // Found a valid location, stop searching
      }

      if (dist < minDistance) {
        minDistance = dist;
        closestLocation = loc;
      }
    }

    if (matchedLocation != null) {
      return GeofenceResult(
        isAllowed: true,
        message: 'Lokasi valid: ${matchedLocation.name}',
        distance: minDistance,
        locationName: matchedLocation.name,
        currentLatitude: position.latitude,
        currentLongitude: position.longitude,
      );
    } else {
      String closestName = closestLocation?.name ?? 'Kampus';
      return GeofenceResult(
        isAllowed: false,
        message:
            'Anda berada ${minDistance.toStringAsFixed(0)} meter dari $closestName.\n'
            'Absensi hanya bisa dilakukan dalam radius ${closestLocation?.radiusMeters.toInt() ?? 100} meter.',
        distance: minDistance,
        locationName: null,
        currentLatitude: position.latitude,
        currentLongitude: position.longitude,
      );
    }
  }

  // 🔹 Buka pengaturan lokasi
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // 🔹 Buka pengaturan app
  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}

// 🔹 Model hasil geofenceUpdated
class GeofenceResult {
  final bool isAllowed;
  final String message;
  final double? distance;
  final String? locationName; // New field
  final double? currentLatitude;
  final double? currentLongitude;

  GeofenceResult({
    required this.isAllowed,
    required this.message,
    this.distance,
    this.locationName,
    this.currentLatitude,
    this.currentLongitude,
  });
}
