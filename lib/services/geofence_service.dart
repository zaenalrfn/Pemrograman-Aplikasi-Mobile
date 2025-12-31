import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
      final baseUrl = dotenv.env['API_BASE'];
      // Debug print to check URL
      debugPrint("Fetching locations from: $baseUrl/attendance-locations");

      final url = Uri.parse('$baseUrl/attendance-locations');

      final storage = const FlutterSecureStorage();
      final token = await storage.read(key: 'token');

      if (token == null) {
        throw Exception("Token tidak ditemukan (Null). Silakan login ulang.");
      }

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("Fetch Locations Status: ${response.statusCode}");
      debugPrint("Fetch Locations Body: ${response.body}");

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        List<dynamic> listData = [];

        if (data is List) {
          listData = data;
        } else if (data is Map && data.containsKey('data')) {
          // Handle pagination or wrapper
          if (data['data'] is List) {
            listData = data['data'];
          }
        }

        return listData
            .map((json) => AttendanceLocationModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
          "Gagal mengambil data lokasi. Status: ${response.statusCode}. Body: ${response.body}",
        );
      }
    } catch (e) {
      debugPrint("Exception fetching locations: $e");
      // Rethrow to be caught by isWithinAllowedArea
      throw Exception("Error fetching locations: $e");
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
    List<AttendanceLocationModel> locations = [];
    try {
      locations = await _fetchLocations();
    } catch (e) {
      // Return error message captured from Exception
      return GeofenceResult(
        isAllowed: false,
        message: e.toString().replaceAll('Exception: ', ''),
        distance: null,
      );
    }

    if (locations.isEmpty) {
      // Kasus: API berhasil diakses tapi data kosong []
      return GeofenceResult(
        isAllowed: false,
        message:
            'Data lokasi absensi kosong (0 lokasi). Silakan hubungi IT/Admin.',
        distance: null,
      );
    }

    // Filter lokasi yang koordinatnya valid (tidak 0,0)
    // Asumsi: latitude/longitude 0.0 dianggap invalid/belum diisi
    List<AttendanceLocationModel> validLocations = locations.where((loc) {
      return loc.latitude != 0.0 && loc.longitude != 0.0;
    }).toList();

    if (validLocations.isEmpty) {
      // Kasus: Data lokasi ada, tapi koordinatnya masih 0 atau kosong
      return GeofenceResult(
        isAllowed: false,
        message:
            'Koordinat lokasi absensi belum diatur dengan benar (Latitude/Longitude kosong). Silakan hubungi Admin.',
        distance: null,
      );
    }

    AttendanceLocationModel? closestLocation;
    double minDistance = double.infinity;
    AttendanceLocationModel? matchedLocation;

    // 2. Iterate to find if inside ANY VALID location
    for (var loc in validLocations) {
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
