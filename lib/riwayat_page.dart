import 'package:flutter/material.dart';
import 'widgets/custom_button_nav.dart';


class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9B7AFD),
        elevation: 0,
        toolbarHeight: 0, // agar tidak ada appbar atas
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header card semester & tahun ajaran
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF9B7AFD),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded,
                                      color: Color(0xFF9B7AFD), size: 18),
                                  SizedBox(width: 6),
                                  Text("Semester",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text("Ganjil",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Row(
                                children: [
                                  Icon(Icons.hourglass_bottom_rounded,
                                      color: Color(0xFF9B7AFD), size: 18),
                                  SizedBox(width: 6),
                                  Text("Tahun Ajaran",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text("2025/2026",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Daftar Kehadiran
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Daftar Kehadiran",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  buildKehadiranCard(
                    "Basis Data",
                    "RABU, 09.00 - 11.00",
                    "2 SKS",
                    "Ruang 205",
                    "7.1%",
                    "1x",
                  ),
                  buildKehadiranCard(
                    "Struktur Data",
                    "RABU, 09.00 - 11.00",
                    "2 SKS",
                    "Lab Komputer",
                    "7.1%",
                    "1x",
                  ),
                  buildKehadiranCard(
                    "Pengantar Big Data",
                    "RABU, 09.00 - 11.00",
                    "2 SKS",
                    "Ruang 301",
                    "7.1%",
                    "1x",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 2, // posisi tab aktif
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

  // Widget card kehadiran
  Widget buildKehadiranCard(String nama, String jadwal, String sks,
      String ruang, String persentase, String jumlah) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nama,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "$jadwal  •  $sks  •  📍 $ruang",
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE9E2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  persentase,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9B7AFD)),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: 0.071,
                  minHeight: 6,
                  backgroundColor: Colors.white,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF9B7AFD)),
                ),
                const SizedBox(height: 6),
                Text(
                  "Jumlah Kehadiran: $jumlah",
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
