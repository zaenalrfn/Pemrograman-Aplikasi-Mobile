import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/custom_button_nav.dart';
import '../data/dummy_scan_data.dart';
import 'camera_scan_page.dart';
import '../services/geofence_service.dart';
import 'package:intl/intl.dart';
import '../models/schedule_model.dart';
import 'providers/scheduleNextCourse_provider.dart';

// tambahan import provider
import '../providers/auth_provider.dart';
import '../providers/schedule_provider.dart';
import '../providers/attendance_provider.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  late Future<ScanData> scanDataFuture;
  bool _isCheckingLocation = false;

  @override
  void initState() {
    super.initState();
    scanDataFuture = fetchScanData();

    // Pastikan nextCourse di-set saat ScanPage dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureNextCourseIsSet();
    });
  }

  Future<void> _ensureNextCourseIsSet() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final scheduleProvider = Provider.of<ScheduleProvider>(
        context,
        listen: false,
      );
      final nextCourseProvider = Provider.of<SchedulenextcourseProvider>(
        context,
        listen: false,
      );

      // Jika user belum dimuat, coba muat dari storage
      if (!authProvider.isLoggedIn) {
        await authProvider.loadUserFromStorage();
      }

      if (!authProvider.isLoggedIn) {
        // Tidak ada user -> tidak bisa load jadwal
        return;
      }

      // Inisialisasi ScheduleProvider dengan token (aman dipanggil berulang)
      scheduleProvider.init(authProvider.token!);

      // Jika belum ada jadwal hari ini, load
      if (scheduleProvider.todaySchedules.isEmpty) {
        await scheduleProvider.loadTodaySchedules(authProvider.user!.id);
      }

      // Set nextCourse di provider yang dipakai UI
      nextCourseProvider.setNextCourse(scheduleProvider.nextSchedule);

      // Pastikan UI ter-refresh
      if (mounted) setState(() {});
    } catch (e) {
      // Jangan crash app — cukup debug print
      // debugPrint('Error memastikan nextCourse di ScanPage: $e');
    }
  }

  Future<void> _handleAbsensi() async {
    // 1. Cek Batas Pertemuan (14 Kali)
    final nextCourseProvider = Provider.of<SchedulenextcourseProvider>(
      context,
      listen: false,
    );
    final nextCourse = nextCourseProvider.nextCourse;

    if (nextCourse != null) {
      final courseId = nextCourse.courseId ?? nextCourse.course?.id;
      if (courseId != null) {
        final attendanceProvider = Provider.of<AttendanceProvider>(
          context,
          listen: false,
        );
        final meetingCount = attendanceProvider.getTotalMeetingCount(courseId);

        if (meetingCount >= 14) {
          _showLimitReachedDialog();
          return;
        }
      }
    }

    setState(() => _isCheckingLocation = true);

    GeofenceResult result = await GeofenceService.isWithinAllowedArea();

    setState(() => _isCheckingLocation = false);

    if (result.isAllowed) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CameraScanPage()),
        );
      }
    } else {
      _showLocationErrorDialog(result.message, result.distance);
    }
  }

  void _showLocationErrorDialog(String message, double? distance) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_off,
                  size: 30,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Lokasi Tidak Valid',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2F2B52),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2F2B52),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFF7165E0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(
                          color: Color(0xFF7165E0),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await GeofenceService.openLocationSettings();
                        await GeofenceService.openAppSettings();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7165E0),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Pengaturan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLimitReachedDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.event_busy,
                  size: 30,
                  color: Colors.orange.shade400,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Batas Absensi Tercapai',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2F2B52),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Mata kuliah ini sudah mencapai 14 pertemuan. Anda tidak dapat melakukan absensi lagi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2F2B52),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7165E0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Mengerti',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nextCourse = context.watch<SchedulenextcourseProvider>().nextCourse;
    final now = DateTime.now();
    final jamMulai = nextCourse?.jamMulai;
    final jamSelesai = nextCourse?.jamSelesai;
    String status = "Belum Mulai";
    Color warnaStatus = Colors.grey;

    if (jamMulai != null && jamSelesai != null) {
      if (now.isAfter(jamMulai) && now.isBefore(jamSelesai)) {
        status = "Absen Dimulai";
        warnaStatus = Colors.green;
      } else if (now.isAfter(jamSelesai)) {
        status = "Selesai";
        warnaStatus = Colors.red;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<ScanData>(
        future: scanDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Data tidak ditemukan"));
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                // 🔥 BAGIAN UI TIDAK DIUBAH SAMA SEKALI
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF7165E0), Color(0xFF9D8EF7)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, 50),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF7165E0,
                                    ).withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // =============================
                                  //         TITLE + BADGE
                                  // =============================
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          nextCourse?.course?.namaMk ?? '-',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF2F2B52),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: warnaStatus.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          status,
                                          style: TextStyle(
                                            color: warnaStatus,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  Text(
                                    "${nextCourse?.course?.kelas ?? '-'} • ${nextCourse?.course?.lecturer?.name ?? '-'} • ${nextCourse?.course?.sks ?? '-'} SKS",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF2F2B52),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // =============================
                                  //         TIME + LOCATION
                                  // =============================
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: Color(0xFF2F2B52),
                                      ),
                                      const SizedBox(width: 6),

                                      Expanded(
                                        child: Text(
                                          "${nextCourse?.jamMulai?.hour.toString().padLeft(2, '0') ?? '-'}:${nextCourse?.jamMulai?.minute.toString().padLeft(2, '0') ?? '-'}"
                                          " - "
                                          "${nextCourse?.jamSelesai?.hour.toString().padLeft(2, '0') ?? '-'}:${nextCourse?.jamSelesai?.minute.toString().padLeft(2, '0') ?? '-'}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF2F2B52),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 16),

                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 16,
                                        color: Color(0xFF2F2B52),
                                      ),
                                      const SizedBox(width: 6),

                                      Expanded(
                                        child: Text(
                                          nextCourse?.ruangan ?? '-',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF2F2B52),
                                          ),
                                        ),
                                      ),
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

                // ——————————————
                // UI BAWAH TIDAK DIUBAH
                // ——————————————
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
                          color: Color(0xFF2F2B52),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Pastikan wajah Anda terlihat jelas dan Anda\nberada di area kelas yang benar",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2F2B52),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 30),

                      _buildTipItem("Pencahayaan cukup terang"),
                      const SizedBox(height: 12),
                      _buildTipItem(
                        "Tidak menggunakan masker atau\nkacamata hitam",
                      ),
                      const SizedBox(height: 12),
                      _buildTipItem(
                        "Berada di area kelas yang sesuai",
                        icon: Icons.location_on,
                      ),

                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isCheckingLocation
                              ? null
                              : _handleAbsensi,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7165E0),
                            disabledBackgroundColor: Colors.grey.shade300,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isCheckingLocation
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
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

  Widget _buildTipItem(String text, {IconData? icon}) {
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
