import 'package:flutter/material.dart';
import 'widgets/custom_button_nav.dart';
import '../data/dummy_jadwal.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Selamat pagi, Ahmad!",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2F2B52),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Senin, 29 September 2025",
                        style: TextStyle(
                          color: Color(0xFF2F2B52),
                          fontSize: 16,
                          fontWeight: FontWeight.normal
                        ),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFEBEBFF),
                    child: Icon(Icons.person, color: Color(0xFF7463F0)),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Materi Kuliah Berikutnya
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF7463F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    // 🔹 Icon Kalender Besar Transparan di Kanan
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Opacity(
                        opacity: 0.15,
                        child: Icon(
                          Icons.calendar_today_rounded,
                          size: 100,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // 🔹 Isi Konten Utama
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Materi Kuliah Berikutnya",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Struktur Data",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: const [
                            Icon(Icons.access_time, color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            Text(
                              "10.00 - 11.40",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 16),
                            Icon(Icons.location_on, color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            Text(
                              "Lab Komputer",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],  
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),


              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Icon(Icons.calendar_today_rounded, color: Color(0xFF2F2B52), size: 24),
                  SizedBox(width: 14,),
                  Text(
                    "Jadwal Hari Ini",
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF2F2B52),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              for (var jadwal in dummyJadwal)
                _jadwalCard(
                  mataKuliah: jadwal.mataKuliah,
                  dosen: jadwal.dosen,
                  kelas: jadwal.kelas,
                  sks: jadwal.sks.toString(),
                  waktu: jadwal.waktu,
                  lokasi: jadwal.lokasi,
                  status: jadwal.status,
                  warnaStatus: _getWarnaStatus(jadwal.status),
                  tombol: jadwal.adaTombol
                      ? ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7463F0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Center(
                            child: Text(
                              "Absensi Sekarang",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                      : null,
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0, // posisi tab aktif
        onTap: (index) {
          // logika pindah halaman
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/beranda');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/scan');
              break;
            case 2:
              // Riwayat, tidak perlu pindah
              Navigator.pushReplacementNamed(context, '/riwayat');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/profil');
              break;
          }
        },
      ),
    );
  }

  Color _getWarnaStatus(String status) {
    switch (status) {
      case "Sesi dibuka":
        return const Color(0xFF7463F0);
      case "Hadir":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _jadwalCard({
  required String mataKuliah,
  required String dosen,
  required String kelas,
  required String sks,
  required String waktu,
  required String lokasi,
  required String status,
  required Color warnaStatus,
  Widget? tombol,
}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 4,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Baris atas
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              mataKuliah,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2F2B52),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: warnaStatus.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(color: warnaStatus, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text("$kelas · $dosen · $sks SKS",
            style: const TextStyle(color: Color(0xFF2F2B52))),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.access_time, size: 18, color: Color(0xFF2F2B52)),
            const SizedBox(width: 6),
            Text(waktu, style: const TextStyle(color: Color(0xFF2F2B52))),
            const SizedBox(width: 16),
            const Icon(Icons.location_on, size: 18, color: Color(0xFF2F2B52)),
            const SizedBox(width: 6),
            Text(lokasi, style: const TextStyle(color: Color(0xFF2F2B52))),
          ],
        ),
        if (tombol != null) ...[
          const SizedBox(height: 12),
          tombol,
        ],
      ],
    ),
  );
}

  
}
