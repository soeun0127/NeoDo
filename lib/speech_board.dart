import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:neodo/audio_provider.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

class SpeechBoardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('스피치 보드')),
      body: FutureBuilder(
        future: audioProvider.fetchAudioFiles(),
        builder: (context, snapshot) {
          if (audioProvider.isLoading) {
            return Center(child: CircularProgressIndicator()); // 로딩 표시
          }
          if (audioProvider.audioList.isEmpty) {
            return Center(child: Text('오디오 파일이 없습니다.'));
          }

          return ListView.builder(
            itemCount: audioProvider.audioList.length,
            itemBuilder: (context, index) {
              final file = audioProvider.audioList[index];

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.mic, color: Colors.white),
                    ),
                    title: Text(
                      file.title,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      '녹음 내용: ${file.record}',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                    onTap: () {
                      // 선택된 오디오 경로를 FeedbackPage로 전달
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FeedbackPage(
                            playAudioPath: file.record,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '목록'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        ],
        onTap: (index) {
          // 네비게이션 로직 추가 가능
        },
      ),
    );
  }
}

class AudioProvider with ChangeNotifier {
  List<Audio> _audioList = [];
  bool _isLoading = false;

  List<Audio> get audioList => _audioList;
  bool get isLoading => _isLoading;

  Future<void> fetchAudioFiles() async {
    final url = 'https://your-backend-url.com/audios'; // 실제 백엔드 URL로 변경
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        _audioList =
            data.map((audioData) => Audio.fromJson(audioData)).toList();
      } else {
        throw Exception('Failed to load audios');
      }
    } catch (error) {
      throw error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class Audio {
  final String id;
  final String userId;
  final String title;
  final String record;

  Audio(
      {required this.id,
      required this.userId,
      required this.title,
      required this.record});

  factory Audio.fromJson(Map<String, dynamic> json) {
    return Audio(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      record: json['record'],
    );
  }
}

/*class FeedbackPage extends StatefulWidget {
  final String speechBoardId; // speech_board_id를 받음
  final String playAudioPath; // 오디오 파일 경로

  const FeedbackPage(
      {super.key, required this.speechBoardId, required this.playAudioPath});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  String convertedText = ""; // 변환된 텍스트
  String feedback = ""; // 피드백
  bool isLoading = true; // 데이터 로딩 상태

  @override
  void initState() {
    super.initState();
    fetchTextAndFeedback(); // 변환된 텍스트 & 피드백 가져오기

    // 오디오 재생 상태 설정
    audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() => duration = d);
    });

    audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() => position = p);
    });

    audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        isPlaying = false;
        position = Duration.zero;
      });
    });

    playAudio(); // 자동으로 오디오 재생
  }

  // 변환된 텍스트와 피드백 가져오기
  Future<void> fetchTextAndFeedback() async {
    try {
      final response = await http.get(Uri.parse(
          "http://localhost:8080/api/speech-boards/${widget.speechBoardId}/feedback"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          convertedText = data['convertedText']; // 변환된 텍스트
          feedback = data['feedback']; // 피드백
          isLoading = false;
        });
      } else {
        print("데이터 가져오기 실패");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("오류 발생: $e");
      setState(() => isLoading = false);
    }
  }

  // 오디오 재생
  Future<void> playAudio() async {
    try {
      await audioPlayer.stop();
      await audioPlayer.setSourceUrl(widget.playAudioPath);
      await audioPlayer.resume();
      setState(() {
        isPlaying = true;
      });
    } catch (e) {
      print("오디오 재생 오류: $e");
    }
  }

  // 시간 포맷 변환 함수
  String formatTime(Duration duration) {
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('스피치 피드백')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator()) // 데이터 로딩 중
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 변환된 텍스트 표시
                  Text(
                    "변환된 텍스트",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(convertedText, style: TextStyle(fontSize: 16)),
                  ),

                  SizedBox(height: 16),

                  // 피드백 표시
                  Text(
                    "피드백",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(feedback, style: TextStyle(fontSize: 16)),
                  ),

                  SizedBox(height: 16),

                  // 오디오 컨트롤러
                  Column(
                    children: [
                      Slider(
                        min: 0,
                        max: duration.inSeconds.toDouble(),
                        value: position.inSeconds.toDouble(),
                        onChanged: (value) async {
                          final newPosition = Duration(seconds: value.toInt());
                          await audioPlayer.seek(newPosition);
                          setState(() => position = newPosition);
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(formatTime(position)),
                          IconButton(
                            icon: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow),
                            onPressed: () async {
                              if (isPlaying) {
                                await audioPlayer.pause();
                              } else {
                                await audioPlayer.resume();
                              }
                              setState(() => isPlaying = !isPlaying);
                            },
                          ),
                          Text(formatTime(duration)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
*/

class FeedbackPage extends StatefulWidget {
  final String playAudioPath;
  const FeedbackPage({super.key, required this.playAudioPath});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  String? currentAudioUrl;
  List<String> audioUrls = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAudioUrls();

    audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() => duration = d);
    });

    audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() => position = p);
    });

    audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        isPlaying = false;
        position = Duration.zero;
      });
    });
  }

  // 백엔드에서 오디오 URL 리스트 가져오기
  Future<void> fetchAudioUrls() async {
    try {
      final response =
          await http.get(Uri.parse("http://localhost:8080/api/speech-boards"));
      if (response.statusCode == 200) {
        setState(() {
          audioUrls = List<String>.from(json.decode(response.body));
          isLoading = false;
        });
      } else {
        print("오디오 리스트 가져오기 실패");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("오류 발생: $e");
      setState(() => isLoading = false);
    }
  }

  // 오디오 재생 함수
  Future<void> playAudio(String url) async {
    try {
      await audioPlayer.stop();
      await audioPlayer.setSourceUrl(url);
      await audioPlayer.resume();
      setState(() {
        currentAudioUrl = url;
        isPlaying = true;
      });
    } catch (e) {
      print("오디오 재생 오류: $e");
    }
  }

  // 시간 포맷 변환 함수
  String formatTime(Duration duration) {
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('오디오 리스트')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : audioUrls.isEmpty
              ? Center(child: Text('오디오 파일이 없습니다.'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: audioUrls.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text("Audio ${index + 1}"),
                            tileColor: currentAudioUrl == audioUrls[index]
                                ? Colors.grey[300]
                                : null, // 선택한 오디오 강조
                            onTap: () => playAudio(audioUrls[index]),
                          );
                        },
                      ),
                    ),
                    if (currentAudioUrl != null)
                      Column(
                        children: [
                          Slider(
                            min: 0,
                            max: duration.inSeconds.toDouble(),
                            value: position.inSeconds.toDouble(),
                            onChanged: (value) async {
                              final newPosition =
                                  Duration(seconds: value.toInt());
                              await audioPlayer.seek(newPosition);
                              setState(() => position = newPosition);
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(formatTime(position)),
                              IconButton(
                                icon: Icon(
                                    isPlaying ? Icons.pause : Icons.play_arrow),
                                onPressed: () async {
                                  if (isPlaying) {
                                    await audioPlayer.pause();
                                  } else {
                                    await audioPlayer.resume();
                                  }
                                  setState(() => isPlaying = !isPlaying);
                                },
                              ),
                              Text(formatTime(duration)),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
    );
  }
}
