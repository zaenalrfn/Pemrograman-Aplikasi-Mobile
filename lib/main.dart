import 'package:flutter/material.dart';
import 'login_page.dart';
import '/beranda_page.dart';
import '/riwayat_page.dart';
import '/scan_page.dart';
// import '/profil_page.dart';

void main() {
  runApp(const MyApp());
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
