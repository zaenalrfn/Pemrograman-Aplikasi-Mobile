import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:passion/models/app_version_model.dart';
import 'package:passion/services/app_version_service.dart';

class AppUpdatesPage extends StatefulWidget {
  const AppUpdatesPage({super.key});

  @override
  State<AppUpdatesPage> createState() => _AppUpdatesPageState();
}

class _AppUpdatesPageState extends State<AppUpdatesPage> {
  final AppVersionService _service = AppVersionService();
  List<AppVersion> _versions = [];
  bool _isLoading = true;
  AppVersion? _latestVersion;

  @override
  void initState() {
    super.initState();
    _loadVersions();
  }

  Future<void> _loadVersions() async {
    try {
      final versions = await _service.getAppVersions();
      if (mounted) {
        setState(() {
          _versions = versions;
          if (versions.isNotEmpty) {
            _latestVersion = versions.first;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal memuat pembaruan: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Force dark mode style for this specific page based on user request/image,
    // or adapt to theme. Image implies dark mode.
    // I'll use Theme-aware colors but stick to the requested aesthetic.
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Colors from the image style
    final backgroundColor = isDarkMode ? Colors.black : const Color(0xFFF5F6FA);
    final cardColor = isDarkMode
        ? const Color(0xFF1E1E2E)
        : Colors.white; // slightly lighter than black
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2F2B52);
    final subTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Pembaruan Aplikasi",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Card (Current/Latest Version)
                  if (_latestVersion != null)
                    _buildTopCard(
                      _latestVersion!,
                      cardColor,
                      textColor,
                      subTextColor,
                    ),

                  const SizedBox(height: 24),

                  Text(
                    "Apa saja yang baru:",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. Version History List
                  ..._versions
                      .map(
                        (v) => _buildVersionItem(
                          v,
                          cardColor,
                          textColor,
                          subTextColor,
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildTopCard(
    AppVersion version,
    Color cardColor,
    Color textColor,
    Color? subTextColor,
  ) {
    final dateStr = DateFormat(
      'd MMMM yyyy',
      'id_ID',
    ).format(version.releaseDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor, // Dark card
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2), // border
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/logo.png',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (ctx, _, __) =>
                    const Icon(Icons.apps, size: 50, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Passion",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Versi ${version.versionNumber} (Terpasang)",
                  style: TextStyle(color: subTextColor, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  "Dirilis $dateStr",
                  style: TextStyle(color: subTextColor, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionItem(
    AppVersion version,
    Color cardColor,
    Color textColor,
    Color? subTextColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        // If adhering strictly to image, no shadow, just flat color on black
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Versi ${version.versionNumber}",
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...version.releaseNotes.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final note = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$index. ",
                    style: TextStyle(color: subTextColor, fontSize: 14),
                  ),
                  Expanded(
                    child: Text(
                      note,
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
