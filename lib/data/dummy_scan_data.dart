// lib/data/dummy_scan_data.dart

import 'dart:async';

// Model data
class ScanData {
  final String courseName;
  final String className;
  final String lecturer;
  final int sks;
  final String time;
  final String location;
  final bool sessionActive;

  ScanData({
    required this.courseName,
    required this.className,
    required this.lecturer,
    required this.sks,
    required this.time,
    required this.location,
    required this.sessionActive,
  });
}

// Fungsi Future dummy
Future<ScanData> fetchScanData() async {
  // Simulasi delay seperti fetch dari API
  await Future.delayed(const Duration(seconds: 1));

  // Data dummy
  return ScanData(
    courseName: 'Struktur Data',
    className: 'Kelas B',
    lecturer: 'Ali Rahman, M.Kom',
    sks: 3,
    time: '13.00 - 14.40',
    location: 'Lab Komputer',
    sessionActive: true,
  );
}
