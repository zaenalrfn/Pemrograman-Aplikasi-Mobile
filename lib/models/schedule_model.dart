class LecturerModel {
  final String id;
  final String? name;
  final String? email;

  LecturerModel({
    required this.id,
    this.name,
    this.email,
  });

  factory LecturerModel.fromJson(Map<String, dynamic> json) {
    return LecturerModel(
      id: json['id'].toString(),
      name: json['name'] ?? '-',
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

class CourseModel {
  final String id;
  final String? kodeMk;
  final String? namaMk;
  final int? sks;
  final String? kelas;
  final String? hari;
  final String? jamMulai; // kept as String because API returns "HH:mm" often
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
      kodeMk: json['kode_mk'] ?? json['kodeMk'],
      namaMk: json['nama_mk'] ?? json['namaMk'],
      sks: json['sks'] is int
          ? json['sks']
          : int.tryParse(json['sks']?.toString() ?? ''),
      kelas: json['kelas'],
      hari: json['hari'],
      jamMulai: json['jam_mulai'] ?? json['jamMulai'],
      jamSelesai: json['jam_selesai'] ?? json['jamSelesai'],
      semester: json['semester'] is int
          ? json['semester']
          : int.tryParse(json['semester']?.toString() ?? ''),
      ruangan: json['ruangan'],
      lecturer: json['lecturer'] != null
          ? LecturerModel.fromJson(Map<String, dynamic>.from(json['lecturer']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode_mk': kodeMk,
      'nama_mk': namaMk,
      'sks': sks,
      'kelas': kelas,
      'hari': hari,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'semester': semester,
      'ruangan': ruangan,
      'lecturer': lecturer?.toJson(),
    };
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
      final s = value.toString().trim();
      try {
        final hhmm = RegExp(r'^\d{1,2}:\d{2}$');
        final hhmmss = RegExp(r'^\d{1,2}:\d{2}:\d{2}$');

        if (hhmm.hasMatch(s)) {
          final parts = s.split(':');
          final now = DateTime.now();
          final h = int.tryParse(parts[0]) ?? 0;
          final m = int.tryParse(parts[1]) ?? 0;
          return DateTime(now.year, now.month, now.day, h, m);
        }

        if (hhmmss.hasMatch(s)) {
          final parts = s.split(':');
          final now = DateTime.now();
          final h = int.tryParse(parts[0]) ?? 0;
          final m = int.tryParse(parts[1]) ?? 0;
          final sec = int.tryParse(parts[2]) ?? 0;
          return DateTime(now.year, now.month, now.day, h, m, sec);
        }

        final parsed = DateTime.tryParse(s);
        if (parsed != null) return parsed;
        return null;
      } catch (_) {
        return null;
      }
    }

    final course = json['course'] != null
        ? CourseModel.fromJson(Map<String, dynamic>.from(json['course']))
        : null;

    DateTime? jm = parseTime(json['jam_mulai'] ?? json['jamMulai'] ?? course?.jamMulai);
    DateTime? js = parseTime(json['jam_selesai'] ?? json['jamSelesai'] ?? course?.jamSelesai);
    DateTime? created = parseTime(json['created_at'] ?? json['createdAt']);

    return ScheduleModel(
      id: json['id'].toString(),
      userId: json['user_id']?.toString(),
      courseId: json['course_id']?.toString(),
      hari: json['hari'] ?? course?.hari,
      ruangan: json['ruangan'] ?? course?.ruangan,
      jamMulai: jm,
      jamSelesai: js,
      createdAt: created,
      course: course,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'hari': hari,
      'ruangan': ruangan,
      'jam_mulai': jamMulai?.toIso8601String(),
      'jam_selesai': jamSelesai?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'course': course?.toJson(),
    };
  }
}
