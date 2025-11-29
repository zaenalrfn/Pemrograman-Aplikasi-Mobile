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
      id: map['id'].toString(),
      namaMk: map['nama_mk']?.toString() ?? '-',
      hari: map['hari']?.toString(),
      jamMulai: map['jam_mulai']?.toString(),
      jamSelesai: map['jam_selesai']?.toString(),
      sks: map['sks'] != null ? int.tryParse(map['sks'].toString()) : null,
      ruangan: map['ruangan']?.toString(),
    );
  }

  static CourseModel fromJson(Map<String, dynamic> json) => CourseModel.fromMap(json);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_mk': namaMk,
      'hari': hari,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'sks': sks,
      'ruangan': ruangan,
    };
  }
}
