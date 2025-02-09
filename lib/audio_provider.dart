import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'audio_file.dart'; // 위에서 만든 모델 파일 import

class AudioProvider with ChangeNotifier {
  List<AudioFile> _audioFiles = [];
  bool _isLoading = false;

  List<AudioFile> get audioFiles => _audioFiles;
  bool get isLoading => _isLoading;

  Future<void> fetchAudioFiles() async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse('http://localhost:8080/api/speech-boards'); // 백엔드 URL
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        _audioFiles = AudioFile.fromJsonList(response.body);
      } else {
        throw Exception('파일을 가져오는 데 실패했습니다.');
      }
    } catch (e) {
      print('오류 발생: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
