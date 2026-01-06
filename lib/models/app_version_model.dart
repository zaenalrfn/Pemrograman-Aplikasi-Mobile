class AppVersion {
  final int id;
  final String versionNumber;
  final DateTime releaseDate;
  final List<String> releaseNotes;
  final bool isMandatory;
  final String? platform;
  final String? downloadUrl;

  AppVersion({
    required this.id,
    required this.versionNumber,
    required this.releaseDate,
    required this.releaseNotes,
    required this.isMandatory,
    this.platform,
    this.downloadUrl,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      id: json['id'],
      versionNumber: json['version_number'],
      releaseDate: DateTime.parse(json['release_date']),
      releaseNotes: List<String>.from(json['release_notes'] ?? []),
      isMandatory: json['is_mandatory'] ?? false,
      platform: json['platform'],
      downloadUrl: json['download_url'],
    );
  }
}
