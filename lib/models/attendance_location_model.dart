class AttendanceLocationModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusMeters;

  AttendanceLocationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });

  factory AttendanceLocationModel.fromJson(Map<String, dynamic> json) {
    return AttendanceLocationModel(
      id: json['id'],
      name: json['name'],
      // Handle numeric string or double inputs from API
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      radiusMeters: double.tryParse(json['radius_meters'].toString()) ?? 100.0,
    );
  }
}
