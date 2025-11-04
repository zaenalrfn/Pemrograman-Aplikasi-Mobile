class Kehadiran {
  final String nama;
  final String jadwal;
  final String sks;
  final String ruang;
  final String persentase;
  final String jumlah;

  Kehadiran({
    required this.nama,
    required this.jadwal,
    required this.sks,
    required this.ruang,
    required this.persentase,
    required this.jumlah,
  });

  factory Kehadiran.fromMap(Map<String, String> map) {
    return Kehadiran(
      nama: map['nama'] ?? '',
      jadwal: map['jadwal'] ?? '',
      sks: map['sks'] ?? '',
      ruang: map['ruang'] ?? '',
      persentase: map['persentase'] ?? '',
      jumlah: map['jumlah'] ?? '',
    );
  }
}

final List<Kehadiran> dataKehadiran = [
  Kehadiran(
    nama: "Basis Data",
    jadwal: "Senin, 08.00 - 10.00",
    sks: "3 SKS",
    ruang: "Ruang 205",
    persentase: "92.3%",
    jumlah: "12x",
  ),
  Kehadiran(
    nama: "Struktur Data",
    jadwal: "Selasa, 10.00 - 12.00",
    sks: "3 SKS",
    ruang: "Lab Komputer 1",
    persentase: "84.6%",
    jumlah: "11x",
  ),
  Kehadiran(
    nama: "Pemrograman Mobile",
    jadwal: "Rabu, 13.00 - 15.00",
    sks: "3 SKS",
    ruang: "Lab Komputer 2",
    persentase: "100%",
    jumlah: "13x",
  ),
  Kehadiran(
    nama: "Pengantar Big Data",
    jadwal: "Kamis, 09.00 - 11.00",
    sks: "2 SKS",
    ruang: "Ruang 301",
    persentase: "76.9%",
    jumlah: "10x",
  ),
  Kehadiran(
    nama: "Kecerdasan Buatan",
    jadwal: "Jumat, 08.00 - 10.00",
    sks: "3 SKS",
    ruang: "Ruang 204",
    persentase: "69.2%",
    jumlah: "9x",
  ),
];
