import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'login_page.dart';
import 'providers/schedule_provider.dart';
import 'providers/scheduleNextCourse_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/auth_provider.dart';

import 'models/schedule_model.dart';

import 'beranda_page.dart';
import 'riwayat_page.dart';
import 'scan_page.dart';
// import 'profil_page.dart'; // ❗ Kalau belum ada filenya, biarkan di-comment

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('id_ID', null);

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => SchedulenextcourseProvider()),
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

      // ===============================
      //   ROUTER UTAMA (AMAN)
      // ===============================
      onGenerateRoute: (settings) {
        switch (settings.name) {

          case '/beranda':
            return MaterialPageRoute(
              builder: (_) => const BerandaPage(),
            );

          case '/riwayat':
            return MaterialPageRoute(
              builder: (_) => const RiwayatPage(),
            );

          case '/profil':
            // ❗ Jika file ProfilPage belum ada → JANGAN dibuka
            // return MaterialPageRoute(builder: (_) => const ProfilPage());
            return null;

          case '/scan':
              return MaterialPageRoute(
                builder: (_) => const ScanPage(),
              );
        }

        return null;
      },
    );
  }
}
