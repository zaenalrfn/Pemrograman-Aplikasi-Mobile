import 'package:absensi_mahasiswa/models/course_model.dart';

class AttendanceModel {
  final String id;
  final String? userId;
  final String? courseId;
  final String? tanggal;
  final String? status;
  final String? method;
  final bool? verified;
  final CourseModel? course;

  AttendanceModel({
    required this.id,
    this.userId,
    this.courseId,
    this.tanggal,
    this.status,
    this.method,
    this.verified,
    this.course,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'].toString(),
      userId: json['user_id']?.toString(),
      courseId: json['course_id']?.toString(),
      tanggal: json['tanggal']?.toString(),
      status: json['status']?.toString(),
      method: json['method']?.toString(),
      verified: json['verified'] ?? false,
      course: json['courses'] != null
          ? CourseModel.fromJson(Map<String, dynamic>.from(json['courses']))
          : null,
    );
  }
}
