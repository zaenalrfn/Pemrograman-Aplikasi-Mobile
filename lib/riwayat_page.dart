import 'package:flutter/material.dart';
import 'widgets/custom_button_nav.dart';
import '../data/dummy_riwayat.dart'; // ganti sesuai nama file model & data Abah

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9B7AFD),
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF9B7AFD),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 25,
                ),
                child: Container(
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
                    children: const [
                      // Semester
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                color: Color(0xFF9B7AFD),
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Semester",
                                style: TextStyle(
                                  color: Color(0xFF2F2B52),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Ganjil",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF2F2B52),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      // Tahun Ajaran
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.hourglass_bottom_rounded,
                                color: Color(0xFF9B7AFD),
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Tahun Ajaran",
                                style: TextStyle(
                                  color: Color(0xFF2F2B52),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            "2025/2026",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF2F2B52),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xFF2F2B52)),
                  ),
                  const SizedBox(height: 15),
                  for (var item in dataKehadiran) buildKehadiranCard(item),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Nav
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/beranda');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/scan');
              break;
            case 2:
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
  Widget buildKehadiranCard(Kehadiran data) {
    // Parsing persentase ke double (contoh: "92.3%" -> 0.923)
    double progressValue =
        double.tryParse(data.persentase.replaceAll('%', ''))! / 100;

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
            data.nama,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF2F2B52)),
          ),
          const SizedBox(height: 4),
          Text(
            "${data.jadwal}  •  ${data.sks}  •  📍 ${data.ruang}",
            style: const TextStyle(color: Color(0xFF2F2B52), fontSize: 13),
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
                  data.persentase,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2F2B52),
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progressValue,
                  minHeight: 6,
                  backgroundColor: Colors.white,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF9B7AFD)),
                ),
                const SizedBox(height: 6),
                Text(
                  "Jumlah Kehadiran: ${data.jumlah}",
                  style: const TextStyle(fontSize: 12, color: Color(0xFF2F2B52)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
