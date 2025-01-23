import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';

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

class MainPage extends StatelessWidget {
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
          'Welcome to the Main Page',
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HomePage()),
                );
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
                print("Sign up pressed");
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButtonWithLabel(
                  context,
                  icon: Icons.mic,
                  label: "녹음",
                  onPressed: () {
                    // 녹음 페이지로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecordingPage(),
                      ),
                    );
                  },
                ),
                _buildButtonWithLabel(
                  context,
                  icon: Icons.upload,
                  label: "음성 업로드",
                  onPressed: pickAndUploadAudio, // 음성 파일 선택 및 업로드
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
            size: 64,
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

class RecordingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class FeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class CoachingPlanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
