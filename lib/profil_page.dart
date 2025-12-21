import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_button_nav.dart';
import '../providers/auth_provider.dart'; // Pastikan path ini sesuai dengan struktur folder Anda

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // --- DATA DUMMY (fallback) ---
  final String _fallbackName = "Zaenal Arifin";
  final String _fallbackNim = "5230411078";
  final String _fallbackSemester = "Semester 5";
  final String _fallbackProdi = "Informatika";
  final String _fallbackEmail = "zaenalfullstack@gmail.com";

  // --- LOGIC LOGOUT ---
  void _handleLogout() async {
    // 1. Tampilkan Dialog Konfirmasi
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // 2. Jika user menekan "Keluar"
    if (confirm == true && mounted) {
      // Ambil instance provider dengan listen: false (karena di dalam fungsi, bukan build)
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Panggil method logout() dari AuthProvider yang Anda buat
      await authProvider.logout();

      // Cek mounted lagi sebelum navigasi (good practice untuk async)
      if (mounted) {
        // Arahkan ke halaman login dan hapus semua history halaman sebelumnya
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data user dari provider untuk ditampilkan di UI
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    final userName = user?.name ?? _fallbackName;
    final userNim = user?.nim ?? user?.nim?.toString() ?? _fallbackNim;
    final userSemester = user?.semester ?? _fallbackSemester;
    final userProdi =
        user?.program_studi ?? user?.program_studi ?? _fallbackProdi;
    final userEmail = user?.email ?? _fallbackEmail;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER
            _buildHeader(userName, userNim, userSemester, userProdi),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  // 2. KARTU INFORMASI USER
                  _buildInfoCard(userEmail),

                  const SizedBox(height: 20),

                  // 3. SECTION FACE RECOGNITION
                  // _buildFaceRecogCard(),
                  const SizedBox(height: 20),

                  // 4. SECTION PENGATURAN
                  _buildSettingsCard(),

                  const SizedBox(height: 20),

                  // 5. TOMBOL LOGOUT (Terhubung ke AuthProvider)
                  _buildLogoutButton(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),

      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 3,
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

  // Widget Header Ungu
  Widget _buildHeader(
    String userName,
    String userId,
    String userSemester,
    String userProdi,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 40, left: 25, right: 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8B80F8), Color(0xFF7463F0)],
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
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(
                Icons.person_outline,
                size: 35,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 15),
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
                    _buildBadge(userProdi, const Color(0xFF00C853)),
                  ],
                ),
              ],
            ),
          ),
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
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Widget Info Kartu (Email)
  Widget _buildInfoCard(String userEmail) {
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
        children: [_buildInfoItem(Icons.email_outlined, "Email", userEmail)],
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
            color: const Color(0xFF7463F0).withOpacity(0.1),
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
                  decoration: title == "Email"
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget Face Recognition
  // Widget _buildFaceRecogCard() {
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.03),
  //           blurRadius: 10,
  //           offset: const Offset(0, 5),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Row(
  //               children: const [
  //                 Icon(Icons.verified_user_outlined, color: Color(0xFF7463F0)),
  //                 SizedBox(width: 10),
  //                 Text(
  //                   "Status Face Recognition",
  //                   style: TextStyle(
  //                     fontWeight: FontWeight.bold,
  //                     color: Color(0xFF2F2B52),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             Container(
  //               padding: const EdgeInsets.symmetric(
  //                 horizontal: 12,
  //                 vertical: 4,
  //               ),
  //               decoration: BoxDecoration(
  //                 color: const Color(0xFF00C853),
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: const Text(
  //                 "Aktif",
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 11,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 15),
  //         Row(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const Icon(
  //               Icons.camera_front_outlined,
  //               color: Color(0xFF7463F0),
  //               size: 26,
  //             ),
  //             const SizedBox(width: 12),
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 const Text(
  //                   "Wajah Terdaftar",
  //                   style: TextStyle(fontWeight: FontWeight.w600),
  //                 ),
  //                 Text(
  //                   "Aktif dan siap digunakan",
  //                   style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 20),
  //         SizedBox(
  //           width: double.infinity,
  //           child: ElevatedButton.icon(
  //             onPressed: () {
  //               print("Daftar Ulang Wajah diklik");
  //             },
  //             icon: const Icon(Icons.camera_alt, color: Colors.white),
  //             label: const Text(
  //               "Daftar Ulang Wajah",
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: const Color(0xFF7463F0),
  //               padding: const EdgeInsets.symmetric(vertical: 14),
  //               elevation: 2,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget Pengaturan
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
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {},
    );
  }

  // === Widget Tombol Logout ===
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed:
            _handleLogout, // Memanggil fungsi yang berisi logika AuthProvider
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text(
          "Keluar Akun",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFE5E5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
