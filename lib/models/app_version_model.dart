class AppVersion {
  final String platform;
  final String versionName;
  final int versionCode;
  final bool forceUpdate;
  final String releaseNotes;

  AppVersion({
    required this.platform,
    required this.versionName,
    required this.versionCode,
    required this.forceUpdate,
    required this.releaseNotes,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      platform: json['platform'],
      versionName: json['version_name'],
      versionCode: json['version_code'],
      forceUpdate: json['force_update'],
      releaseNotes: json['release_notes'],
    );
  }
}
