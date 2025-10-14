import 'package:absensi_mahasiswa/data/models/onboarding_model.dart';
import 'package:absensi_mahasiswa/data/repositories/onboarding_repository.dart';
import 'package:absensi_mahasiswa/ui/widgets/onboarding_content.dart';
import 'package:absensi_mahasiswa/ui/widgets/page_indicator.dart';
import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  // Controller untuk PageView
  final PageController _pageController = PageController();
  
  // Repository untuk ambil data
  final OnboardingRepository _repository = OnboardingRepository();
  
  // Data onboarding
  late List<OnboardingModel> _onboardingData;
  
  // Current page index
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Ambil data dari repository
    _onboardingData = _repository.getOnboardingData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Method untuk pindah ke halaman berikutnya
  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  // Method untuk skip/finish onboarding
  void _finishOnboarding() {
    _repository.completeOnboarding();
    // Navigate ke home page
    Navigator.pushReplacementNamed(context, '/home');
  }

  // Method untuk convert icon string ke IconData
  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'person':
        return Icons.account_circle_outlined;
      case 'payment':
        return Icons.payment_outlined;
      case 'face':
        return Icons.face_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8B5CF6),
              Color(0xFF7C3AED),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Tombol Lewati
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    'Lewati',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              // PageView untuk konten onboarding
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    final data = _onboardingData[index];
                    return OnboardingContent(
                      title: data.title,
                      description: data.description,
                      icon: _getIcon(data.icon),
                    );
                  },
                ),
              ),

              // Bottom section: Indicator + Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Page Indicator
                    PageIndicator(
                      currentPage: _currentPage,
                      totalPages: _onboardingData.length,
                    ),
                    SizedBox(height: 32),

                    // Tombol Lanjut/Mulai
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF7C3AED),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentPage == _onboardingData.length - 1
                              ? 'Mulai'
                              : 'Lanjut',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}