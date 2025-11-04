import 'package:geolocator/geolocator.dart';
import 'dart:math' show cos, sqrt, asin, sin, pi;

class GeofenceService {
  // Lokasi yang diizinkan (ubah sesuai link Google Maps)
  static const double allowedLatitude = -7.756594393550913;
  static const double allowedLongitude = 110.34407829464112;
  static const double radiusInMeters = 100.0; // radius 100 meter

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
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // 🔹 Hitung jarak antar dua koordinat (pakai Haversine formula)
  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meter
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
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

  // 🔹 Cek apakah user berada dalam area
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

    double distance = calculateDistance(
      position.latitude,
      position.longitude,
      allowedLatitude,
      allowedLongitude,
    );

    bool isAllowed = distance <= radiusInMeters;

    return GeofenceResult(
      isAllowed: isAllowed,
      message: isAllowed
          ? 'Lokasi Anda valid untuk absensi.'
          : 'Anda berada ${distance.toStringAsFixed(0)} meter dari lokasi kelas.\nAbsensi hanya bisa dilakukan dalam radius ${radiusInMeters.toInt()} meter.',
      distance: distance,
      currentLatitude: position.latitude,
      currentLongitude: position.longitude,
    );
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

// 🔹 Model hasil geofence
class GeofenceResult {
  final bool isAllowed;
  final String message;
  final double? distance;
  final double? currentLatitude;
  final double? currentLongitude;

  GeofenceResult({
    required this.isAllowed,
    required this.message,
    this.distance,
    this.currentLatitude,
    this.currentLongitude,
  });
}
