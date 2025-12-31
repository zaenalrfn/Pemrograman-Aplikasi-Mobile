import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'providers/auth_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/scheduleNextCourse_provider.dart';
import 'services/face_recognition_service.dart';

class CameraScanPage extends StatefulWidget {
  const CameraScanPage({super.key});

  @override
  State<CameraScanPage> createState() => _CameraScanPageState();
}

class _CameraScanPageState extends State<CameraScanPage> {
  CameraController? _controller;
  bool _isProcessing = false;
  final FaceRecognitionService _faceService = FaceRecognitionService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      // Cari kamera depan
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium, // Reduce resolution for faster upload
        enableAudio: false,
      );

      await _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isProcessing) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // 1. Ambil Foto
      final imageXFile = await _controller!.takePicture();
      final File imageFile = File(imageXFile.path);

      if (!mounted) return;

      // 2. Siapkan Data User & Course
      final authProvider = context.read<AuthProvider>();
      final nextCourseProvider = context.read<SchedulenextcourseProvider>();
      final attendanceProvider = context.read<AttendanceProvider>();

      final user = authProvider.user;
      final nextCourse = nextCourseProvider.nextCourse;

      if (user == null) {
        throw Exception("User tidak ditemukan/belum login.");
      }
      if (nextCourse == null) {
        throw Exception("Tidak ada jadwal kuliah saat ini.");
      }

      // Format nama file: NIM_NAMA
      // Pastikan membersihkan karakter aneh jika parno
      final String safeName = user.name
          .replaceAll(RegExp(r'[^a-zA-Z0-9_ ]'), '')
          .trim();
      final String fileName = "${user.nim}_$safeName";

      final now = DateTime.now();

      // 3. Cek Double Attendance (Moved Up)
      // Pastikan courseId tersedia
      final cId = nextCourse.courseId ?? nextCourse.course?.id;
      if (cId != null && attendanceProvider.hasAttendedToday(cId)) {
        if (!mounted) return;
        _showErrorDialog(
          "Anda sudah melakukan absensi untuk mata kuliah ini hari ini.",
        );
        setState(() => _isProcessing = false);
        return;
      }

      // 4. Cek Waktu (Time Constraint)
      final jamMulai = nextCourse.jamMulai;
      final jamSelesai = nextCourse.jamSelesai;

      if (jamMulai != null && jamSelesai != null) {
        // CASE 1: Belum Mulai (Too Early) -> Cuma Blok, Jangan Absenkan
        if (now.isBefore(jamMulai)) {
          if (!mounted) return;
          _showErrorDialog(
            "Kelas belum dimulai. Absensi baru dapat dilakukan mulai pukul ${DateFormat('HH:mm').format(jamMulai)}.",
          );
          setState(() => _isProcessing = false);
          return;
        }

        // CASE 2: Sudah Selesai (Too Late) -> Blok + Auto Absen (Tidak Hadir)
        if (now.isAfter(jamSelesai)) {
          final tanggal = DateFormat('yyyy-MM-dd').format(now);

          final success = await attendanceProvider.submitAttendance(
            userId: user.id,
            courseId: nextCourse.courseId ?? nextCourse.course?.id ?? '',
            tanggal: tanggal,
            status: 'alpha', // Changed to 'alpha' to satisfy backend
            method: 'manual', // Changed to 'manual' to satisfy backend
            photoCapture: '-',
            verified: false,
          );

          if (!mounted) return;

          if (success) {
            _showErrorDialog(
              // Using ErrorDialog style but message indicates status recorded
              "Kelas sudah selesai pada pukul ${DateFormat('HH:mm').format(jamSelesai)}. Status Anda dicatat sebagai 'Tidak Hadir'.",
            );
          } else {
            _showErrorDialog(
              "Kelas sudah selesai, namun gagal menyimpan status 'Tidak Hadir' ke server.",
            );
          }

          setState(() => _isProcessing = false);
          return;
        }
      }

      // 5. Kirim ke Face Recognition API

      // 5. Kirim ke Face Recognition API
      final result = await _faceService.predict(
        imageFile: imageFile,
        name: fileName,
      );

      if (result['success'] == true) {
        // 4. Jika sukses, Submit Attendance ke Backend Laravel
        final now = DateTime.now();
        final tanggal = DateFormat('yyyy-MM-dd').format(now);

        // Ambil data hasil deteksi (name & accuracy)
        // Service returns: { 'success': true, 'data': { 'name': '...', 'similarity': 99.9, ... } }

        final data = result['data'] ?? {};
        String detectedName = data['name'] ?? '-';
        String detectedNpm = (data['npm'] ?? '').toString();
        double accuracy = (data['similarity'] is num)
            ? (data['similarity'] as num).toDouble()
            : 0.0;

        // VERIFIKASI NPM
        // Pastikan NPM dari hasil deteksi wajah SAMA dengan NIM usernya yang sedang login
        if (detectedNpm != user.nim) {
          _showErrorDialog(
            "NIM tidak cocok! Wajah terdeteksi sebagai $detectedNpm, sedangkan Anda login sebagai ${user.nim}.",
          );
          return;
        }

        // Clean up name if it has format NIM_Name_xx
        // The API might return "5221911012_Debora_05"
        // Let's display it as is or clean it. The user request showed raw name.
        // We will display raw name.

        final successAbsen = await attendanceProvider.submitAttendance(
          userId: user.id,
          // Prioritaskan courseId dari schedule, lalu dari objek course, lalu fallback (kosong, yang akan gagal di backend jika wajib)
          courseId: nextCourse.courseId ?? nextCourse.course?.id ?? '',
          tanggal: tanggal,
          status: 'hadir',
          method: 'face_recognition',
          photoCapture: "$fileName.jpg",
          verified: true,
        );

        if (!mounted) return;

        if (successAbsen) {
          _showSuccessDialog(detectedName, accuracy);
        } else {
          _showErrorDialog("Gagal mencatat absensi ke server.");
        }
      } else {
        // Wajah tidak dikenali atau error lain
        final data = result['data'];
        String message = result['message'] ?? "Wajah tidak dikenali.";

        if (data != null && data['status'] == 'unknown') {
          message =
              "Wajah tidak dikenali.\n\nPastikan wajah terlihat jelas dan pencahayaan cukup.";
        }

        _showErrorDialog(message);
      }
    } catch (e) {
      debugPrint('Error accessing camera/api: $e');
      if (mounted) _showErrorDialog("Terjadi kesalahan sistem: $e");
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSuccessDialog(String name, double accuracy) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7165E0), Color(0xFF9D8EF7)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 50,
                  color: Color(0xFF7165E0),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Absensi berhasil!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Menampilkan Nama dan Akurasi
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Akurasi: ${accuracy.toStringAsFixed(2)}%',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Selamat mengikuti perkuliahan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup dialog
                    Navigator.of(
                      context,
                    ).pop(true); // Kembali ke scan page dengan result true
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Oke',
                    style: TextStyle(
                      color: Color(0xFF7165E0),
                      fontSize: 16,
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

  void _showErrorDialog(String message) {
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
                  Icons.warning_amber_rounded,
                  size: 30,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Absensi Gagal',
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Coba Lagi',
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF524B92), Color(0xFF8B80F8)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Scan Wajah',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Konten Utama
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Camera Preview
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child:
                          _controller != null &&
                              _controller!.value.isInitialized
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width:
                                        _controller!.value.previewSize!.height,
                                    height:
                                        _controller!.value.previewSize!.width,
                                    child: CameraPreview(_controller!),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    width: 220,
                                    height: 280,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(140),
                                      border: Border.all(
                                        color: _isProcessing
                                            ? Colors.green
                                            : Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_isProcessing)
                                  Container(
                                    color: Colors.black.withOpacity(0.3),
                                    child: const Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'Verifikasi Wajah...',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF7165E0),
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    'Posisikan wajah Anda di dalam frame',
                    style: TextStyle(color: Color(0xFF2F2B52), fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  // Tombol Capture
                  GestureDetector(
                    onTap: _isProcessing ? null : _takePicture,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isProcessing
                            ? Colors.grey
                            : const Color(0xFF7165E0),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7165E0).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _isProcessing
                          ? null
                          : const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 32,
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
