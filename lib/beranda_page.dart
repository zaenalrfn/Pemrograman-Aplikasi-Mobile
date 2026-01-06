import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/schedule_model.dart';
import '../providers/auth_provider.dart';
import '../providers/schedule_provider.dart';
import 'providers/scheduleNextCourse_provider.dart';
import '../widgets/custom_button_nav.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Pindahkan load ke post frame callback untuk menghindari masalah setState/notifyListeners saat build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadUserAndSchedules();
    });

    // Auto-refresh tiap 1 menit
    _timer = Timer.periodic(const Duration(minutes: 1), (_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final scheduleProvider = Provider.of<ScheduleProvider>(
        context,
        listen: false,
      );
      final nextCourseProvider = Provider.of<SchedulenextcourseProvider>(
        context,
        listen: false,
      );

      if (authProvider.isLoggedIn) {
        await scheduleProvider.loadTodaySchedules(authProvider.user!.id);
        nextCourseProvider.setNextCourse(scheduleProvider.nextSchedule);
      }

      if (mounted) setState(() {});
    });
  }

  Future<void> loadUserAndSchedules() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // 1. Cek User Login (Data sudah ada dari AuthWrapper, tidak perlu load ulang)
    // Jika authProvider belum ready (jarang terjadi di sini), return.
    if (!authProvider.isLoggedIn) return;

    final user = authProvider.user!;
    final token = authProvider.token!;

    // 2. Init ScheduleProvider
    final scheduleProvider = Provider.of<ScheduleProvider>(
      context,
      listen: false,
    );
    scheduleProvider.init(token);

    // Load schedules
    // 3. Load schedules
    // Gunakan try-catch di sini jika perlu, tapi Provider sudah handle error state.
    await scheduleProvider.loadTodaySchedules(user.id);

    // PENTING: Cek mounted setelah await agar tidak crash jika user pindah halaman
    if (!mounted) return;

    // 4. Set nextCourse di provider
    final nextCourseProvider = Provider.of<SchedulenextcourseProvider>(
      context,
      listen: false,
    );
    // Pastikan scheduleProvider.nextSchedule valid
    nextCourseProvider.setNextCourse(scheduleProvider.nextSchedule);

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final todaySchedules = scheduleProvider.todaySchedules;
    final nextCourseProvider = Provider.of<SchedulenextcourseProvider>(context);
    final nextCourse = nextCourseProvider.nextCourse;

    final name = authProvider.user?.name.split(' ').first ?? '';
    final tanggal = DateFormat(
      'EEEE, dd MMMM yyyy',
      'id_ID',
    ).format(DateTime.now());

    var hour = DateTime.now().hour;
    String greeting;
    if (hour < 11) {
      greeting = 'Selamat pagi';
    } else if (hour < 15) {
      greeting = 'Selamat siang';
    } else if (hour < 18) {
      greeting = 'Selamat sore';
    } else {
      greeting = 'Selamat malam';
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2F2B52);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: scheduleProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  if (authProvider.isLoggedIn) {
                    await scheduleProvider.loadTodaySchedules(
                      authProvider.user!.id,
                      forceReload: true,
                    );
                    nextCourseProvider.setNextCourse(
                      scheduleProvider.nextSchedule,
                    );
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                            children: [
                              Text(
                                "$greeting, $name",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tanggal,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                context,
                                '/profil',
                              );
                            },
                            child: const CircleAvatar(
                              radius: 20,
                              backgroundColor: Color(0xFFEBEBFF),
                              child: Icon(
                                Icons.person,
                                color: Color(0xFF7463F0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Next Course Card
                      if (nextCourse != null)
                        _nextCourseCard(nextCourse)
                      else
                        _noCourseCard(),
                      const SizedBox(height: 24),
                      // Title Jadwal
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            color: textColor,
                            size: 24,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            "Jadwal Hari Ini",
                            style: TextStyle(
                              fontSize: 20,
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Jadwal List
                      if (scheduleProvider.error != null)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 40,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Gagal memuat jadwal:\n${scheduleProvider.error}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    scheduleProvider.loadTodaySchedules(
                                      authProvider.user!.id,
                                      forceReload: true,
                                    );
                                  },
                                  child: const Text("Coba Lagi"),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (todaySchedules.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              "Tidak ada jadwal hari ini 😊",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        Column(
                          children: todaySchedules
                              .map(_buildJadwalItem)
                              .toList(),
                        ),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
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

  Widget _buildJadwalItem(ScheduleModel jadwal) {
    final now = DateTime.now();
    final jamMulai = jadwal.jamMulai;
    final jamSelesai = jadwal.jamSelesai;

    String status = "Belum Mulai";
    Color warnaStatus = Colors.grey;
    Widget? tombol;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2F2B52);

    if (jamMulai != null && jamSelesai != null) {
      if (now.isAfter(jamMulai) && now.isBefore(jamSelesai)) {
        status = "Absen Dimulai";
        warnaStatus = Colors.green;
        tombol = ElevatedButton(
          onPressed: () {
            // Set course yang dipilih ini sebagai nextCourse supaya di halaman scan langsung muncul
            Provider.of<SchedulenextcourseProvider>(
              context,
              listen: false,
            ).setNextCourse(jadwal);

            Navigator.pushNamed(context, '/scan');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            "Mulai Absen",
            style: TextStyle(color: Colors.white),
          ),
        );
      } else if (now.isAfter(jamSelesai)) {
        status = "Selesai";
        warnaStatus = Colors.red;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  jadwal.course?.namaMk ?? '-',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
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
          Text(
            "${jadwal.course?.kelas ?? '-'} · ${jadwal.course?.lecturer?.name ?? '-'} · ${jadwal.course?.sks ?? 0} SKS",
            style: TextStyle(color: textColor),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 18, color: textColor),
              const SizedBox(width: 6),
              Text(
                "${jadwal.jamMulai?.hour.toString().padLeft(2, '0')}:${jadwal.jamMulai?.minute.toString().padLeft(2, '0')} - "
                "${jadwal.jamSelesai?.hour.toString().padLeft(2, '0')}:${jadwal.jamSelesai?.minute.toString().padLeft(2, '0')}",
                style: TextStyle(color: textColor),
              ),
              const SizedBox(width: 16),
              Icon(Icons.location_on, size: 18, color: textColor),
              const SizedBox(width: 6),
              Text(jadwal.ruangan ?? '-', style: TextStyle(color: textColor)),
            ],
          ),
          if (tombol != null) ...[const SizedBox(height: 12), tombol],
        ],
      ),
    );
  }

  Widget _nextCourseCard(ScheduleModel nextCourse) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF7463F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
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
          Text(
            nextCourse.course?.namaMk ?? '-',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                "${nextCourse.jamMulai?.hour.toString().padLeft(2, '0')}:${nextCourse.jamMulai?.minute.toString().padLeft(2, '0')} - "
                "${nextCourse.jamSelesai?.hour.toString().padLeft(2, '0')}:${nextCourse.jamSelesai?.minute.toString().padLeft(2, '0')}",
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _noCourseCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF7463F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        "Tidak ada materi kuliah berikutnya hari ini 😊",
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
