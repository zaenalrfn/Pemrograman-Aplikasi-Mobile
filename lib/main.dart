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

  final apiBase = dotenv.env['API_BASE'] ?? '';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // AttendanceProvider dibuat di sini; token akan di-push via ProxyProvider update
        ChangeNotifierProxyProvider<AuthProvider, AttendanceProvider>(
          create: (_) => AttendanceProvider(token: ''),
          update: (_, auth, att) {
            att ??= AttendanceProvider(token: auth.token ?? '');
            att.updateToken(auth.token ?? '');
            return att;
          },
        ),
        ChangeNotifierProvider(create: (_) => SchedulenextcourseProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..loadUserFromStorage(), // muat user bila ada
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
      home: const LoginPage(),
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
