import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'sign_up.dart';
import 'package:path/path.dart' as p;
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(MyApp());
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

class HomePage extends StatelessWidget {
  Future<void> uploadAudioFile(File audioFile) async {
    final uri = Uri.parse('http://your-server-url/upload'); // 서버 URL로 변경

    var request = http.MultipartRequest('POST', uri);

    var file = await http.MultipartFile.fromPath('file', audioFile.path,
        contentType: MediaType('audio', 'mpeg') // 파일 형식에 맞게 설정
        );
    request.files.add(file);

    // 서버로 파일 전송
    var response = await request.send();

    if (response.statusCode == 200) {
      print('파일 업로드 성공');
    } else {
      print('파일 업로드 실패');
    }
  }

  Future<void> pickAndUploadAudio() async {
    // 음성 파일 선택
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      File file = File(result.files.single.path!);
      print('선택된 파일 경로: ${file.path}'); // 디버깅용 로그
      await uploadAudioFile(file); // 선택한 파일 업로드
    } else {
      print("파일 선택이 취소되었습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('NeoDo'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            icon: Icon(Icons.logout),
          )
        ],
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
                  label: "피드백",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FeedbackPage(),
                      ),
                    );
                  },
                ),
                _buildButtonWithLabel(
                  context,
                  icon: Icons.assignment,
                  label: "코칭 플랜",
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
                    pickAndUploadAudio();
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

class FeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("피드백"),
      ),
      body: Center(
        child: Text("피드백 페이지 내용"),
      ),
    );
  }
}

class CoachingPlanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("코칭 플랜"),
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
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  Duration _recordedDuration = Duration.zero;
  late String _filePath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    _recorder = FlutterSoundRecorder();

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
    _filePath = 'audio_${DateTime.now().millisecondsSinceEpoch}.aac';
    _startRecording();
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
    super.dispose();
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _recordedDuration = Duration.zero;
    });

    await _recorder!.startRecorder(
      toFile: _filePath,
      codec: Codec.aacADTS,
    );

    // 녹음 시간 갱신
    _updateDuration();
  }

  Future<void> _pauseRecording() async {
    if (_recorder!.isRecording) {
      await _recorder!.pauseRecorder();
      setState(() {
        _isRecording = false;
      });
    } else if (_recorder!.isPaused) {
      await _recorder!.resumeRecorder();
      setState(() {
        _isRecording = true;
      });
      _updateDuration();
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
      if (!await newDir.exists()) {
        await newDir.create(recursive: true); // recordings 디렉터리 생성
      }

      final newFile = File(p.join(newDir.path, 'audio.mp3')); // 'audio.mp3'로 저장
      await audioFile.copy(newFile.path); // 기존 파일을 새로운 위치로 복사
      return newFile.path; // 새로운 경로 반환
    } catch (e) {
      print('Error saving recording: $e');
      return ''; // 오류 발생 시 빈 문자열 반환
    }
  }

  void _updateDuration() {
    // Timer를 사용하여 녹음 시간을 갱신
    Future.delayed(Duration(seconds: 1), () {
      if (_isRecording) {
        setState(() {
          _recordedDuration += Duration(seconds: 1);
        });
        _updateDuration(); // 계속해서 갱신
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  // 완료 후 선택지 다이얼로그 표시
  void _showCompletionDialog(String filePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('발표 종류'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // 첫 번째 선택지: 녹음 다시 하기
                Navigator.pop(context);
                _startRecording();
              },
              child: Text('일반 발표표'),
            ),
            TextButton(
              onPressed: () {
                // 두 번째 선택지: 저장된 파일 확인
                Navigator.pop(context);
                print('저장된 파일 경로: $filePath');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('저장된 파일 경로: $filePath')),
                );
              },
              child: Text('공모전 및 프로젝트트'),
            ),
            TextButton(
              onPressed: () {
                // 세 번째 선택지: 다른 작업
                Navigator.pop(context);
                print('다른 작업 선택됨');
              },
              child: Text('비지니스스'),
            ),
            TextButton(
              onPressed: () {
                // 네 번째 선택지: 취소
                Navigator.pop(context);
              },
              child: Text('강연'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('녹음'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 타이머 표시
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _formatDuration(_recordedDuration),
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ),
          // 버튼들
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 100.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 취소 버튼
                ElevatedButton(
                  onPressed: () {
                    _stopRecording();
                    Navigator.pop(context); // 홈으로 돌아가기
                  },
                  child: Text('취소'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
                // 녹음 버튼
                GestureDetector(
                  onTap: _pauseRecording,
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.red,
                    child: Icon(
                      _isRecording ? Icons.pause : Icons.mic,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                // 완료 버튼
                ElevatedButton(
                  onPressed: () async {
                    await _stopRecording();
                  },
                  child: Text('완료'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
