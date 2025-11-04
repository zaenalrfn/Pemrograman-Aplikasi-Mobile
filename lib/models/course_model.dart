class CourseModel {
  final String id;
  final String namaMk;
  final String? hari;
  final String? jamMulai;
  final String? jamSelesai;
  final int? sks;
  final String? ruangan;

  CourseModel({
    required this.id,
    required this.namaMk,
    this.hari,
    this.jamMulai,
    this.jamSelesai,
    this.sks,
    this.ruangan,
  });

  factory CourseModel.fromMap(Map<String, dynamic> map) {
    return CourseModel(
      id: map['id'],
      namaMk: map['nama_mk'] ?? '-',
      hari: map['hari'],
      jamMulai: map['jam_mulai'],
      jamSelesai: map['jam_selesai'],
      sks: map['sks'],
      ruangan: map['ruangan'],
    );
  }

  static CourseModel fromJson(Map<String, dynamic> json) => CourseModel.fromMap(json);
}
