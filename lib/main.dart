import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart' as sound;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'sign_up.dart';
import 'package:path/path.dart' as p;
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'audio_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AudioProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  //Service service = Service();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NeoDo'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
            child: Text(
              "Login",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: Center(
        child: Text(
          '너의 스피치를 도와줄게',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                "NeoDo",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 32),

            // Email Field
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),

            SizedBox(height: 16),

            // Password Field
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),

            SizedBox(height: 32),

            // Login Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text("Log In", style: TextStyle(fontSize: 18)),
              onPressed: () {
                //SignUp().login(context); 원래 코드
                Navigator.push(context,
                    MaterialPageRoute(builder: (builder) => HomePage()));
              },
            ),

            SizedBox(height: 16),

            // Sign Up Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text("Sign Up", style: TextStyle(fontSize: 18)),
              onPressed: () {
                SignUp().signUp(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // GlobalKey 추가

  // 🔹 파일 업로드 함수 (서버와 동기화)
  Future<void> uploadAudioFile(File audioFile) async {
    final uri = Uri.parse(
        'http://localhost:8080/api/speech-boards/recordings'); // 서버 URL 수정

    var request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        audioFile.path,
        contentType: MediaType('audio', 'mp4'), // 파일 형식 맞추기
      ),
    );

    request.fields['userId'] = 'your_user_id';
    request.fields['title'] = 'your_title';
    request.fields['category'] = 'your_category';

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        print('✅ 파일 업로드 성공');

        // JSON 응답 받기
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> jsonResponse = json.decode(responseBody);

        // 파일이 업로드된 후 서버에서 최신 데이터 가져오기
        if (context.mounted) {
          await Provider.of<AudioProvider>(context, listen: false)
              .fetchAudioFiles();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('파일 업로드 완료: ${jsonResponse["file_name"]}')),
        );
      } else {
        print('파일 업로드 실패: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('업로드 중 오류 발생: $e');
    }
  }

  // 🔹 파일 선택 및 업로드 실행 함수
  Future<void> pickAndUploadAudio(BuildContext context) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null) {
      File file = File(result.files.single.path!);
      print('📂 선택된 파일 경로: ${file.path}');

      await uploadAudioFile(file);
    } else {
      print("파일 선택이 취소되었습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Scaffold에 GlobalKey 추가
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('NeoDo'),
        centerTitle: true,
        automaticallyImplyLeading: false, // 기본 back 버튼 숨기기
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            // Drawer 열기
            _scaffoldKey.currentState?.openDrawer(); // _scaffoldKey로 Drawer 열기
          },
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              // 사용자 정보 영역
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.purple),
                accountName: Text(
                  '홍길동', // 실제 사용자 이름을 여기에 표시
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  'userI', // 실제 사용자 ID를 여기에 표시
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.amber,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    // 로그아웃 버튼
                    ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('로그아웃'),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                    ),
                    // 필요한 경우 여기에 더 많은 ListTile을 추가할 수 있습니다.
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 64),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButtonWithLabel(
                  context,
                  icon: Icons.person,
                  label: "스피치 보드",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SpeechBoardPage(),
                      ),
                    );
                  },
                ),
                _buildButtonWithLabel(
                  context,
                  icon: Icons.assignment,
                  label: "스피치 코칭",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CoachingPlanPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 64),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButtonWithLabel(
                  context,
                  icon: Icons.upload,
                  label: "업로드",
                  onPressed: () {
                    pickAndUploadAudio(context);
                  },
                ),
                _buildButtonWithLabel(
                  context,
                  icon: Icons.mic,
                  label: "녹음",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecordingPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonWithLabel(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(150, 100),
            backgroundColor: Colors.purple,
            foregroundColor: Colors.amber,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onPressed,
          child: Icon(
            icon,
            size: 80,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8), // 버튼과 텍스트 간 간격
        Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

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
          if (audioProvider.audioFiles.isEmpty) {
            return Center(child: Text('오디오 파일이 없습니다.'));
          }

          return ListView.builder(
            itemCount: audioProvider.audioFiles.length,
            itemBuilder: (context, index) {
              final file = audioProvider.audioFiles[index];

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
                      file.fileName,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      '녹음 날짜: ${file.createdAt.year}-${file.createdAt.month.toString().padLeft(2, '0')}-${file.createdAt.day.toString().padLeft(2, '0')} ${file.createdAt.hour}:${file.createdAt.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                    onTap: () {
                      // 선택된 오디오 경로를 FeedbackPage로 전달
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FeedbackPage(
                            playAudioPath: file.fileUrl,
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

class CoachingPlanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("스피치 코칭"),
      ),
      body: Center(
        child: Text("코칭 플랜 페이지 내용"),
      ),
    );
  }
}

//녹음 기능 구현, 녹음 페이지
class RecordingPage extends StatefulWidget {
  @override
  _RecordingPageState createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  sound.FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  Duration _recordedDuration = Duration.zero;
  Timer? _timer;
  late String _filePath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    _recorder = sound.FlutterSoundRecorder();

    // 마이크 권한 요청
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('마이크 권한이 필요합니다.')),
      );
      Navigator.pop(context);
      return;
    }

    await _recorder!.openRecorder();
    _startRecording();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder?.closeRecorder();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final directory = await getApplicationDocumentsDirectory();
    _filePath = p.join(
        directory.path, 'audio_${DateTime.now().millisecondsSinceEpoch}.aac');

    setState(() {
      _isRecording = true;
      _recordedDuration = Duration.zero;
    });

    await _recorder!
        .startRecorder(toFile: _filePath, codec: sound.Codec.aacMP4);

    // 타이머 시작 (1초마다 업데이트)
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isRecording) {
        setState(() {
          _recordedDuration += Duration(seconds: 1);
        });
      }
    });
  }

  Future<void> _pauseRecording() async {
    if (_recorder!.isRecording) {
      await _recorder!.pauseRecorder();
      setState(() => _isRecording = false);
    } else if (_recorder!.isPaused) {
      await _recorder!.resumeRecorder();
      setState(() => _isRecording = true);
    }
  }

  Future<void> _stopRecording() async {
    if (_recorder != null) {
      await _recorder!.stopRecorder();
    }

    // 녹음 완료 후 경로 받아오기
    final path = await _recorder!.stopRecorder();
    setState(() {
      _isRecording = false;
    });

    if (path != null) {
      // 파일 로컬 저장
      String savedFilePath = await saveRecordingLocally(path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('녹음 저장 완료: $savedFilePath')),
      );
      // 다이얼로그 표시
      _showCompletionDialog(savedFilePath);
    }
  }

  Future<String> saveRecordingLocally(String path) async {
    try {
      final audioFile = File(path);
      if (!audioFile.existsSync()) return '';

      final directory = await getApplicationDocumentsDirectory();
      final newDir = Directory(p.join(directory.path, 'recordings'));
      if (!await newDir.exists()) await newDir.create(recursive: true);

      final newFile = File(p.join(
          newDir.path, 'audio_${DateTime.now().millisecondsSinceEpoch}.mp3'));
      await audioFile.copy(newFile.path);
      await uploadAudioFile(newFile);
      return newFile.path;
    } catch (e) {
      print('녹음 저장 중 오류 발생: $e');
      return '';
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  String _selectedAtmosphere = ''; // 분위기
  String _selectedPurpose = ''; // 목적
  String _selectedScale = ''; // 규모
  String _selectedAudience = ''; // 청중 수준
  TextEditingController _timeLimitController =
      TextEditingController(); // 제한 시간 입력

  void _showCompletionDialog(String filePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('발표 종류'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // 분위기 선택
                DropdownButton<String>(
                  value:
                      _selectedAtmosphere.isEmpty ? null : _selectedAtmosphere,
                  hint: Text('분위기'),
                  isExpanded: true,
                  alignment: Alignment.center,
                  items: [
                    '공식적',
                    '비공식적',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        textAlign: TextAlign.center, // 텍스트 중앙 정렬
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedAtmosphere = newValue!;
                    });
                  },
                ),
                // 목적 선택
                DropdownButton<String>(
                  value: _selectedPurpose.isEmpty ? null : _selectedPurpose,
                  hint: Text('목적'),
                  isExpanded: true,
                  alignment: Alignment.center,
                  items: [
                    '정보 전달',
                    '보고',
                    '설득',
                    '토론',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        textAlign: TextAlign.center, // 텍스트 중앙 정렬
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedPurpose = newValue!;
                    });
                  },
                ),
                // 규모 선택
                DropdownButton<String>(
                  value: _selectedScale.isEmpty ? null : _selectedScale,
                  hint: Text('규모'),
                  isExpanded: true,
                  alignment: Alignment.center,
                  items: [
                    '소규모 (~10명)',
                    '중규모 (~50명)',
                    '대규모 (50명 이상)',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        textAlign: TextAlign.center, // 텍스트 중앙 정렬
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedScale = newValue!;
                    });
                  },
                ),
                // 청중 수준 선택
                DropdownButton<String>(
                  value: _selectedAudience.isEmpty ? null : _selectedAudience,
                  hint: Text('청중 수준'),
                  isExpanded: true,
                  alignment: Alignment.center,
                  items: [
                    '일반 대중',
                    '관련 지식 보유자',
                    '전문가',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        textAlign: TextAlign.center, // 텍스트 중앙 정렬
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedAudience = newValue!;
                    });
                  },
                ),
                // 제한 시간 입력 (선택 사항)
                TextField(
                  controller: _timeLimitController,
                  decoration: InputDecoration(
                    labelText: '제한 시간 (선택)',
                    hintText: '시간을 입력하세요 (예: 30)',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // 모든 항목이 선택된 경우에만 녹음 완료 처리
                if (_selectedAtmosphere.isNotEmpty &&
                    _selectedPurpose.isNotEmpty &&
                    _selectedScale.isNotEmpty &&
                    _selectedAudience.isNotEmpty) {
                  setState(() {
                    _completeRecording(filePath);
                  });
                  Navigator.pop(context); // 다이얼로그 닫기
                  _goHomePage(); // HomePage로 이동
                } else {
                  // 필수 항목이 모두 선택되지 않았을 경우 경고
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('모든 항목을 선택해주세요.'),
                  ));
                }
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 녹음 완료 후 카테고리와 함께 처리하는 함수
  void _completeRecording(String filePath) {
    String timeLimit = _timeLimitController.text.isNotEmpty
        ? _timeLimitController.text
        : '제한 시간 없음';

    // 선택된 카테고리와 함께 녹음을 완료하는 처리
    print('녹음 완료 - 분위기: $_selectedAtmosphere');
    print('목적: $_selectedPurpose');
    print('규모: $_selectedScale');
    print('청중 수준: $_selectedAudience');
    print('제한 시간: $timeLimit');
    print('파일 경로: $filePath');

    // HomePage로 이동하면서 카테고리 정보도 전달할 수 있다면 전달
    _goHomePage();
  }

// HomePage로 돌아가는 함수
  void _goHomePage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (route) => false, // 기존의 모든 화면을 제거하고 HomePage로 이동
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('녹음')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _formatDuration(_recordedDuration),
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 100.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _stopRecording();
                    Navigator.pop(context);
                  },
                  child: Text('취소'),
                ),
                GestureDetector(
                  onTap: _pauseRecording,
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.red,
                    child: Icon(_isRecording ? Icons.pause : Icons.mic,
                        color: Colors.white, size: 36),
                  ),
                ),
                ElevatedButton(
                  onPressed: _stopRecording,
                  child: Text('완료'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//벡엔드로 파일 전송
Future<void> uploadAudioFile(File audioFile) async {
  final uri = Uri.parse('http://localhost:8080/api/speech-boards/recordings');
  var request = http.MultipartRequest('POST', uri);
  var file = await http.MultipartFile.fromPath('audio', audioFile.path);
  request.files.add(file);
  var response = await request.send();
  if (response.statusCode == 200) {
    print('파일 업로드 성공');
  } else {
    print('파일 업로드 실패');
  }
}

//백엔드에서 파일 목록 가져오기
Future<List<AudioFile>> fetchAudioFiles() async {
  final response =
      await http.get(Uri.parse('http://localhost:8080/api/speech-boards'));
  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((item) => AudioFile.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load audio files');
  }
}

//오디오 파일 list
class AudioFile {
  final String file;
  final String userId;
  final String title;
  final List<String> categories; // category는 List로 받음

  AudioFile({
    required this.file,
    required this.userId,
    required this.title,
    required this.categories, // categories를 추가
  });

  // JSON 파싱 시 categories 추가
  factory AudioFile.fromJson(Map<String, dynamic> json) {
    return AudioFile(
      file: json['file'],
      userId: json['userId'],
      title: json['title'],
      categories:
          List<String>.from(json['category']), // category 필드도 List<String>으로 파싱
    );
  }
}

//오디오 재생 페이지
class AudioPlayerPage extends StatefulWidget {
  final AudioFile audioFile;

  AudioPlayerPage({required this.audioFile});

  @override
  _AudioPlayerPageState createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    await _audioPlayer.setSource(UrlSource(widget.audioFile.file));
    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) {
        setState(() => duration = d);
      }
    });
    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) {
        setState(() => position = p);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.audioFile.title)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Slider(
            value: position.inSeconds.toDouble(),
            max: duration.inSeconds.toDouble(),
            onChanged: (value) {
              _audioPlayer.seek(Duration(seconds: value.toInt()));
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  if (isPlaying) {
                    _audioPlayer.pause();
                  } else {
                    _audioPlayer.resume();
                  }
                  setState(() {
                    isPlaying = !isPlaying;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
