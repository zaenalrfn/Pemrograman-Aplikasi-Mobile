import 'package:flutter/material.dart';
import '../widgets/custom_button_nav.dart';

// Jika kamu punya file model/service sendiri, uncomment baris di bawah ini
// import '../models/user_model.dart';
// import '../services/user_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // --- DATA DUMMY (Ganti dengan data dari API/UserService kamu nanti) ---
  final String userName = "Zaenal Arifin";
  final String userId = "5230411078";
  final String userSemester = "Semester 5";
  final String userProdi = "Informatika";
  final String userEmail = "zaenalfullstack@gmail.com";
  final String userPhone = "082177359177";
  final String userFaculty = "Sains dan Teknologi";
  final String userRegDate = "15 Agustus 2023";
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // Background abu-abu muda
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER (Bagian Ungu Atas)
            _buildHeader(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  // 2. KARTU INFORMASI USER
                  _buildInfoCard(),
                  
                  const SizedBox(height: 20),

                  // 3. SECTION FACE RECOGNITION
                  _buildFaceRecogCard(),
                  
                  const SizedBox(height: 20),

                  // 4. SECTION PENGATURAN BAWAH
                  _buildSettingsCard(),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // 5. BOTTOM NAVIGATION BAR
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/beranda');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/scan');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/riwayat');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/profil');
              break;
          }
        },
      ),
    );
  }

  // ================= WIDGET BUILDERS =================

  // 1. HEADER BUILDER
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 40, left: 25, right: 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8B80F8), Color(0xFF7463F0)], // Gradasi Ungu
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Row(
        children: [
          // Foto Profil
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(Icons.person_outline, size: 35, color: Colors.white),
            ),
          ),
          const SizedBox(width: 15),
          
          // Detail Nama & Prodi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userId,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildBadge(userSemester, const Color(0xFF9F94FF)),
                    const SizedBox(width: 8),
                    _buildBadge(userProdi, const Color(0xFF00C853)), // Hijau
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text, 
        style: const TextStyle(
          color: Colors.white, 
          fontSize: 11, 
          fontWeight: FontWeight.w500
        )
      ),
    );
  }

  // 2. INFO CARD BUILDER
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoItem(Icons.email_outlined, "Email", userEmail),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
          _buildInfoItem(Icons.phone_outlined, "Nomor Telepon", userPhone),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
          _buildInfoItem(Icons.location_on_outlined, "Fakultas", userFaculty),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
          _buildInfoItem(Icons.calendar_today_outlined, "Tanggal Registrasi", userRegDate),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF7463F0).withOpacity(0.1), // Ungu Pudar
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF7463F0), size: 22),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F2B52),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  decoration: title == "Email" ? TextDecoration.underline : TextDecoration.none,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  // 3. FACE RECOGNITION CARD BUILDER
  Widget _buildFaceRecogCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.verified_user_outlined, color: Color(0xFF7463F0)),
                  SizedBox(width: 10),
                  Text(
                    "Status Face Recognition",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2F2B52)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853), // Hijau
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Aktif",
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const SizedBox(height: 15),
          
          // Keterangan Wajah
           Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               const Icon(Icons.camera_front_outlined, color: Color(0xFF7463F0), size: 26),
               const SizedBox(width: 12),
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const Text("Wajah Terdaftar", style: TextStyle(fontWeight: FontWeight.w600)),
                   Text("Aktif dan siap digunakan", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                 ],
               )
            ],
          ),
          
          const SizedBox(height: 20),

          // Tombol Daftar Ulang
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                 print("Daftar Ulang Wajah diklik");
              },
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: const Text(
                "Daftar Ulang Wajah",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7463F0), // Warna Ungu Utama
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. SETTINGS CARD BUILDER
  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildSettingItem(Icons.settings_outlined, "Pengaturan Aplikasi"),
          const Divider(height: 1, indent: 50),
          _buildSettingItem(Icons.shield_outlined, "Keamanan & Privasi"),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF7463F0)),
      title: Text(
        title, 
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {},
    );
  }
}