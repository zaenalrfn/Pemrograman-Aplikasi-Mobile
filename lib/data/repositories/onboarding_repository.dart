import 'package:absensi_mahasiswa/data/models/onboarding_model.dart';

class OnboardingRepository {
  // Method untuk mengambil data onboarding
  List<OnboardingModel> getOnboardingData() {
    return [
      OnboardingModel(
        title: 'Selamat datang',
        description:
            'Aplikasi ini dirancang untuk memberikan kenyamanan dalam mengakses layanan kesehatan',
        icon: 'person',
      ),
      OnboardingModel(
        title: 'Keterangan Berbayar',
        description:
            'Dapatkan informasi lengkap mengenai berbagai layanan berbayar yang tersedia',
        icon: 'payment',
      ),
      OnboardingModel(
        title: 'Registrasi Wajah\ndi aplikasi anda',
        description:
            'Verifikasi registrasi yang lebih aman dengan menggunakan wajah pada saat login',
        icon: 'face',
      ),
    ];
  }

  // Method untuk menyimpan status onboarding selesai
  Future<void> completeOnboarding() async {
    // Bisa pakai SharedPreferences untuk save status
    await Future.delayed(Duration(milliseconds: 100));
  }
}