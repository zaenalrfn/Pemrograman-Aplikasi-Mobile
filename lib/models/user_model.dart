class UserModel {
  final String id;
  final String nim;
  final String name;
  final String email;
  final String program_studi;
  final String semester;
  final String kelas;

  UserModel({
    required this.id,
    required this.nim,
    required this.name,
    required this.email,
    required this.program_studi,
    required this.semester,
    required this.kelas,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      nim: json['nim']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      program_studi: json['program_studi']?.toString() ?? '',
      semester: json['semester']?.toString() ?? '',
      kelas: json['kelas']?.toString() ?? '',
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel.fromJson(map);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nim': nim,
      'name': name,
      'email': email,
      'program_studi': program_studi,
      'semester': semester,
      'kelas': kelas,
    };
  }
}
