import 'dart:convert';

class AudioFile {
  final String fileName;
  final DateTime createdAt;
  final String fileUrl; // 파일 URL (필요 시)

  AudioFile({
    required this.fileName,
    required this.createdAt,
    required this.fileUrl,
  });

  factory AudioFile.fromJson(Map<String, dynamic> json) {
    return AudioFile(
      fileName: json['file_name'],
      fileUrl: json['file_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  static List<AudioFile> fromJsonList(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => AudioFile.fromJson(json)).toList();
  }
}
