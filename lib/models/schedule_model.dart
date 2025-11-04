class LecturerModel {
  final String id;
  final String? name;

  LecturerModel({
    required this.id,
    this.name,
  });

  factory LecturerModel.fromJson(Map<String, dynamic> json) {
    return LecturerModel(
      id: json['id'].toString(),
      name: json['name'] ?? json['nama_dosen'] ?? '-',
    );
  }
}

class CourseModel {
  final String id;
  final String? kodeMk;
  final String? namaMk;
  final int? sks;
  final String? kelas;
  final String? hari;
  final String? jamMulai;
  final String? jamSelesai;
  final int? semester;
  final String? ruangan;
  final LecturerModel? lecturer;

  CourseModel({
    required this.id,
    this.kodeMk,
    this.namaMk,
    this.sks,
    this.kelas,
    this.hari,
    this.jamMulai,
    this.jamSelesai,
    this.semester,
    this.ruangan,
    this.lecturer,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'].toString(),
      kodeMk: json['kode_mk'],
      namaMk: json['nama_mk'],
      sks: json['sks'] is int ? json['sks'] : int.tryParse(json['sks']?.toString() ?? ''),
      kelas: json['kelas'],
      hari: json['hari'],
      jamMulai: json['jam_mulai'],
      jamSelesai: json['jam_selesai'],
      semester: json['semester'] is int ? json['semester'] : int.tryParse(json['semester']?.toString() ?? ''),
      lecturer: json['lecturers'] != null
          ? LecturerModel.fromJson(Map<String, dynamic>.from(json['lecturers']))
          : null,
    );
  }
}

class ScheduleModel {
  final String id;
  final String? userId;
  final String? courseId;
  final String? hari;
  final String? ruangan;
  final DateTime? jamMulai;
  final DateTime? jamSelesai;
  final DateTime? createdAt;
  final CourseModel? course;

  ScheduleModel({
    required this.id,
    this.userId,
    this.courseId,
    this.hari,
    this.ruangan,
    this.jamMulai,
    this.jamSelesai,
    this.createdAt,
    this.course,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseTime(dynamic value) {
      if (value == null) return null;
      try {
        // format "08:00:00" → DateTime hari ini
        if (value is String && value.length == 8 && value.contains(':')) {
          final now = DateTime.now();
          final parts = value.split(':');
          return DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }
        // format ISO (2025-11-04T07:00:00+00:00)
        return DateTime.tryParse(value.toString());
      } catch (_) {
        return null;
      }
    }

    return ScheduleModel(
      id: json['id'].toString(),
      userId: json['user_id']?.toString(),
      courseId: json['course_id']?.toString(),
      hari: json['hari'],
      ruangan: json['ruangan'],
      jamMulai: parseTime(json['jam_mulai']),
      jamSelesai: parseTime(json['jam_selesai']),
      createdAt: parseTime(json['created_at']),
      course: json['courses'] != null
          ? CourseModel.fromJson(Map<String, dynamic>.from(json['courses']))
          : null,
    );
  }
}
