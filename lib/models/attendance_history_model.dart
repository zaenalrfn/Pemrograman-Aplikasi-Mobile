import 'schedule_model.dart';

class AttendanceModel {
  final String id;
  final String? userId;
  final String? courseId;
  final DateTime? tanggal;
  final String? status;
  final String? method;
  final String? photoCapture;
  final bool? verified;
  final CourseModel? course; // CourseModel dari schedule_model.dart

  AttendanceModel({
    required this.id,
    this.userId,
    this.courseId,
    this.tanggal,
    this.status,
    this.method,
    this.photoCapture,
    this.verified,
    this.course,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'].toString(),
      userId: json['user_id']?.toString(),
      courseId: json['course_id']?.toString(),
      tanggal: json['tanggal'] != null ? DateTime.tryParse(json['tanggal']) : null,
      status: json['status']?.toString(),
      method: json['method']?.toString(),
      photoCapture: json['photo_capture']?.toString(),
      verified: json['verified'] ?? false,
      course: json['course'] != null
          ? CourseModel.fromJson(Map<String, dynamic>.from(json['course']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'tanggal': tanggal?.toIso8601String(),
      'status': status,
      'method': method,
      'photo_capture': photoCapture,
      'verified': verified,
      'course': course?.toJson(),
    };
  }
}
