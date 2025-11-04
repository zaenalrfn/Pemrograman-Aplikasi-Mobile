class JadwalModel {
  final String mataKuliah;
  final String dosen;
  final String kelas;
  final int sks;
  final String waktu;
  final String lokasi;
  final String status;
  final bool adaTombol;

  JadwalModel({
    required this.mataKuliah,
    required this.dosen,
    required this.kelas,
    required this.sks,
    required this.waktu,
    required this.lokasi,
    required this.status,
    this.adaTombol = false,
  });
}

List<JadwalModel> dummyJadwal = [
  JadwalModel(
    mataKuliah: "Struktur Data",
    dosen: "Ali Romli",
    kelas: "Kelas B",
    sks: 3,
    waktu: "13.00 - 14.40",
    lokasi: "Lab Komputer",
    status: "Sesi dibuka",
    adaTombol: true,
  ),
  JadwalModel(
    mataKuliah: "Basis Data",
    dosen: "Sri Wulandari",
    kelas: "Kelas B",
    sks: 2,
    waktu: "09.00 - 11.00",
    lokasi: "Ruang 205",
    status: "Hadir",
  ),
  JadwalModel(
    mataKuliah: "Pengantar Big Data",
    dosen: "Budi Santoso",
    kelas: "Kelas A",
    sks: 3,
    waktu: "15.00 - 16.40",
    lokasi: "Ruang 301",
    status: "Belum Dimulai",
  ),
];