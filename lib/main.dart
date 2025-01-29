import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

import 'sign_up.dart';

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
                SignUp().login(context);
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
  late final String _filePath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    _recorder = FlutterSoundRecorder();

    // Request microphone permission
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Microphone permission is required')),
      );
      Navigator.pop(
          context); // Return to the previous page if permission is denied
      return;
    }

    await _recorder!.openRecorder();
    _filePath = 'audio_${DateTime.now().millisecondsSinceEpoch}.aac';
    _startRecording();
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _recordedDuration = Duration.zero;
    });

    await _recorder?.startRecorder(
      toFile: _filePath,
      codec: Codec.aacADTS,
    );

    // Start the timer to update recording duration
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
    await _recorder?.stopRecorder();
    setState(() {
      _isRecording = false;
    });
  }

  void _updateDuration() {
    Future.delayed(Duration(seconds: 1), () {
      if (_isRecording) {
        setState(() {
          _recordedDuration += Duration(seconds: 1);
        });
        _updateDuration(); // Continue updating
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
    super.dispose();
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
          // Timer at the top
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _formatDuration(_recordedDuration),
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ),
          // Buttons at the bottom
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 100.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cancel Button
                ElevatedButton(
                  onPressed: () {
                    _stopRecording();
                    Navigator.pop(context); // Go back to HomePage
                  },
                  child: Text('취소'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
                // Recording Button
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
                // Done Button
                ElevatedButton(
                  onPressed: () async {
                    await _stopRecording();
                    // Do something with the recorded file (_filePath)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Recording saved to $_filePath')),
                    );
                    Navigator.pop(context); // Go back to HomePage
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
