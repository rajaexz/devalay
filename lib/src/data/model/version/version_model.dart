class VersionResponse {
  final String latestVersion;
  final bool forceUpdate;
  final String? updateMessage;
  final String? storeUrl;
  final String? releaseNotes;

  VersionResponse({
    required this.latestVersion,
    required this.forceUpdate,
    this.updateMessage,
    this.storeUrl,
    this.releaseNotes,
  });

  factory VersionResponse.fromJson(Map<String, dynamic> json) {
    return VersionResponse(
      latestVersion: json['latest_version']?.toString() ?? '',
      // Properly handle boolean conversion
      forceUpdate: json['is_update_required'] == true || 
                   json['is_update_required'] == 1 ||
                   json['is_update_required']?.toString().toLowerCase() == 'true',
      updateMessage: json['update_message']?.toString() ?? json['release_notes']?.toString(),
      storeUrl: json['download_url']?.toString(),
      releaseNotes: json['release_notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latest_version': latestVersion,
      'is_update_required': forceUpdate,
      'update_message': updateMessage,
      'store_url': storeUrl,
      'release_notes': releaseNotes,
    };
  }
}