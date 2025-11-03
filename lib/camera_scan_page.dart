import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScanPage extends StatefulWidget {
  const CameraScanPage({super.key});

  @override
  State<CameraScanPage> createState() => _CameraScanPageState();
}

class _CameraScanPageState extends State<CameraScanPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isProcessing = false;

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
        ResolutionPreset.high,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      setState(() {});
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      
      // Simulasi proses pengenalan wajah
      await Future.delayed(const Duration(seconds: 2));
      
      // Tampilkan dialog sukses
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      print('Error taking picture: $e');
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF7165E0),
                Color(0xFF9D8EF7),
              ],
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
                'Absensi berhasil! Selamat mengikuti\nperkuliahan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup dialog
                    Navigator.of(context).pop(); // Kembali ke scan page
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header dengan gradient ungu
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF524B92), // 0%
                  Color(0xFF8B80F8), // 100%
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

          // Konten utama dengan padding
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Container kamera dengan aspect ratio dan border radius
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9), // Grey background
                        borderRadius: BorderRadius.circular(20),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _controller != null && _initializeControllerFuture != null
                          ? FutureBuilder<void>(
                              future: _initializeControllerFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.done) {
                                  return Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      // Camera Preview
                                      FittedBox(
                                        fit: BoxFit.cover,
                                        child: SizedBox(
                                          width: _controller!.value.previewSize!.height,
                                          height: _controller!.value.previewSize!.width,
                                          child: CameraPreview(_controller!),
                                        ),
                                      ),
                                      
                                      // Frame oval untuk wajah (tengah)
                                      Center(
                                        child: Container(
                                          width: 220,
                                          height: 280,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.circular(140),
                                            border: Border.all(
                                              color: _isProcessing ? Colors.green : Colors.white,
                                              width: 3,
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      // Processing indicator
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
                                                  'Memproses...',
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
                                  );
                                } else {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF7165E0),
                                    ),
                                  );
                                }
                              },
                            )
                          : const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF7165E0),
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Instruksi
                  const Text(
                    'Posisikan wajah Anda di dalam frame',
                    style: TextStyle(
                      color: Color(0xFF2F2B52),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tombol capture
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