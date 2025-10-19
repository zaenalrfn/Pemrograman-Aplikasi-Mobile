import 'package:flutter/material.dart';
import 'widgets/custom_button_nav.dart';
import '../data/dummy_scan_data.dart';
class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  late Future<ScanData> scanDataFuture;

  @override
  void initState() {
    super.initState();
    scanDataFuture = fetchScanData(); // ambil data dummy
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<ScanData>(
        future: scanDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // tampilkan loading saat nunggu data
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // tampilkan error jika gagal ambil data
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Data tidak ditemukan"));
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header gradient
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF7165E0),
                        Color(0xFF9D8EF7),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Stack(
                        clipBehavior: Clip.none, // biar card boleh keluar dari container
                        children: [
                          // Card putih keluar sedikit ke bawah
                          Transform.translate(
                            offset: const Offset(0, 50), // geser ke bawah 40px
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF7165E0).withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header nama mata kuliah + status sesi
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        data.courseName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF2F2B52)
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1EDFF),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          data.sessionActive ? "Sesi Aktif" : "Tidak Aktif",
                                          style: const TextStyle(
                                            color: Color(0xFF6A5AE0),
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "${data.className} • ${data.lecturer} • ${data.sks} SKS",
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF2F2B52)),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time,
                                          size: 16, color: Color(0xFF2F2B52)),
                                      const SizedBox(width: 6),
                                      Text(data.time,
                                          style: const TextStyle(
                                              fontSize: 12, color: Color(0xFF2F2B52))),
                                      const SizedBox(width: 16),
                                      const Icon(Icons.location_on_outlined,
                                          size: 16, color: Color(0xFF2F2B52)),
                                      const SizedBox(width: 6),
                                      Text(data.location,
                                          style: const TextStyle(
                                              fontSize: 12, color: Color(0xFF2F2B52))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),


                // Konten bawah
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(top: 20),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8E5FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          size: 40,
                          color: Color(0xFF7165E0),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "Siap untuk Absensi?",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2F2B52)
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Pastikan wajah Anda terlihat jelas dan Anda\nberada di area kelas yang benar",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFF2F2B52), height: 1.5),
                      ),
                      const SizedBox(height: 30),
                      _buildTipItem("Pencahayaan cukup terang"),
                      const SizedBox(height: 12),
                      _buildTipItem("Tidak menggunakan masker atau\nkacamata hitam"),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // fungsi absensi
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7165E0),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Absensi Sekarang",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/beranda');
              break;
            case 1:
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

  Widget _buildTipItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
