import 'package:absensi_mahasiswa/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../widgets/custom_button_nav.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;

      if (user != null && user.id.isNotEmpty) {
        context.read<AttendanceProvider>().loadData(user.id);
      } else {
        // fallback kalau user belum ada
        authProvider.loadUser().then((_) {
          final newUser = authProvider.user;
          if (newUser != null && newUser.id.isNotEmpty) {
            context.read<AttendanceProvider>().loadData(newUser.id);
          } else {
            print("User ID kosong, skip load data");
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9B7AFD),
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 25,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Daftar Kehadiran",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2F2B52),
                          ),
                        ),
                        // const SizedBox(height: 15),

                        // Loop courses, bukan attendances
                        for (var schedule in provider.schedules)
                          _buildKehadiranCard(
                            nama: schedule.course?.namaMk ?? '-',
                            jadwal: _formatJadwal(schedule.course),
                            sks: "${schedule.course?.sks ?? 0} SKS",
                            ruang: schedule.ruangan ?? '-',
                            persentase: "${(provider.getAttendancePercentage(schedule.course!.id) * 100).toStringAsFixed(1)}%",
                            jumlah: "${provider.getHadirCount(schedule.course!.id)}x",
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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

  String _formatJadwal(course) {
    try {
      final hari = course.hari ?? '-';

      // Ambil jam mulai
      String start = '-';
      if (course.jamMulai != null) {
        if (course.jamMulai is DateTime) {
          start =
              "${course.jamMulai.hour.toString().padLeft(2, '0')}:${course.jamMulai.minute.toString().padLeft(2, '0')}";
        } else if (course.jamMulai is String) {
          // Asumsi format string: "HH:mm:ss" atau "HH:mm"
          List<String> parts = (course.jamMulai as String).split(":");
          if (parts.length >= 2) {
            start = "${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}";
          }
        }
      }

      // Ambil jam selesai
      String end = '-';
      if (course.jamSelesai != null) {
        if (course.jamSelesai is DateTime) {
          end =
              "${course.jamSelesai.hour.toString().padLeft(2, '0')}:${course.jamSelesai.minute.toString().padLeft(2, '0')}";
        } else if (course.jamSelesai is String) {
          List<String> parts = (course.jamSelesai as String).split(":");
          if (parts.length >= 2) {
            end = "${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}";
          }
        }
      }

      return "$hari, $start - $end";
    } catch (e) {
      return "-";
    }
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF9B7AFD),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
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
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _HeaderItem(
                icon: Icons.calendar_today_rounded,
                title: "Semester",
                value: "Ganjil",
              ),
              _HeaderItem(
                icon: Icons.hourglass_bottom_rounded,
                title: "Tahun Ajaran",
                value: "2025/2026",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKehadiranCard({
    required String nama,
    required String jadwal,
    required String sks,
    required String ruang,
    required String persentase,
    required String jumlah,
  }) {
    double progressValue = double.tryParse(persentase.replaceAll('%', ''))! / 100;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
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
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2F2B52),
            ),
          ),
          const SizedBox(height: 4),
 Text(
    "$jadwal  •  $sks  •  📍 $ruang",
    style: const TextStyle(color: Color(0xFF2F2B52), fontSize: 13),
  ),
          Container(
            margin: const EdgeInsets.only(top: 10),
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
        "Jumlah Kehadiran: $jumlah",
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF2F2B52),
        ),
      ),
    ],
  ),
),

        ],
      ),
    );
  }
}

class _HeaderItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _HeaderItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Color(0xFF9B7AFD), size: 18),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF2F2B52),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF2F2B52),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
