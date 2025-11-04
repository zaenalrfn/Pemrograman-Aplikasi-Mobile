import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'login_page.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'providers/schedule_provider.dart';
import '/beranda_page.dart';
import '/riwayat_page.dart';
import '/scan_page.dart';
// import '/profil_page.dart';

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
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),

      // Halaman pertama yang muncul saat aplikasi dibuka
      home: const LoginPage(),

      // Semua route halaman
      routes: {
        '/beranda': (context) => const BerandaPage(),
        '/scan': (context) => const ScanPage(),
        '/riwayat': (context) => const RiwayatPage(),
        // '/profil': (context) => const ProfilPage(),
      },
    );
  }
}
