import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'login_page.dart';
import 'providers/schedule_provider.dart';
import 'providers/scheduleNextCourse_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/auth_provider.dart';

import 'profil_page.dart';
import 'beranda_page.dart';
import 'riwayat_page.dart';
import 'scan_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('id_ID', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        // ChangeNotifierProvider(create: (_) => AuthProvider()), // HAPUS INI (Redundant)
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => SchedulenextcourseProvider()),
        // Gunakan satu AuthProvider saja yang sekaligus load user
        ChangeNotifierProvider(
          create: (_) =>
              AuthProvider()..loadUserFromStorage(), // muat user bila ada
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Absensi Mahasiswa',
      theme: ThemeData(fontFamily: 'Poppins'),
      home: const AuthWrapper(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/beranda':
            return MaterialPageRoute(builder: (_) => const BerandaPage());
          case '/riwayat':
            return MaterialPageRoute(builder: (_) => const RiwayatPage());
          case '/profil':
            return MaterialPageRoute(builder: (_) => const ProfilePage());
          case '/scan':
            return MaterialPageRoute(builder: (_) => const ScanPage());
        }
        return null;
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Dengarkan perubahan pada AuthProvider
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // 1. Jika masih loading data dari storage (splash screen sederhana)
        if (!auth.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Jika sudah selesai, cek apakah user login?
        if (auth.isLoggedIn) {
          return const BerandaPage();
        }

        // 3. Jika belum login, tampilkan halaman Login
        return const LoginPage();
      },
    );
  }
}
