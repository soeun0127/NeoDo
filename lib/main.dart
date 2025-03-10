import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart' as sound;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:audioplayers/audioplayers.dart';
//import 'package:dio/dio.dart';
import 'dart:convert';
//import 'audio_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';
//import 'speech_board.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'user.dart';
import 'apiService.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AudioProvider()), // AudioProvider 추가
      ],
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
                login(context);
                /*Navigator.push(
                  context,
                  MaterialPageRoute(builder: (builder) => HomePage()),
                );*/
              },
            ),

            SizedBox(height: 32),

            // Sign Up Button
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                  );
                },
                child: Text(
                  "회원가입",
                  style: TextStyle(
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> login(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://ed8b-203-232-234-11.ngrok-free.app/api/users/login'), // ✅ 실제 API 주소
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        String? accessToken = response.headers['accessToken'];
        if (accessToken != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', accessToken);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      } else {
        _showErrorDialog(context, '로그인 실패: ${response.body}');
      }
    } catch (e) {
      _showErrorDialog(context, '서버 요청 중 오류 발생: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SignUp")),
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
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: "UserName",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),

            SizedBox(height: 16),
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
              child: Text("Sign Up", style: TextStyle(fontSize: 18)),
              onPressed: () {
                signUp(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> signUp(BuildContext context) async {
    final String username = usernameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;

    try {
      final response = await http.post(
        Uri.parse(
            "https://ed8b-203-232-234-11.ngrok-free.app/api/users/signup"), // 실제 API 주소 사용
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {'username': username, 'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        _showErrorDialog(context, '회원가입 실패: ${response.body}');
      }
    } catch (e) {
      _showErrorDialog(context, '서버 요청 중 오류 발생: $e');
    }
  }

  Future<void> login(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://ed8b-203-232-234-11.ngrok-free.app/api/users/login'), // 실제 API 주소 사용
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      } else {
        _showErrorDialog(context, '로그인 실패: ${response.body}');
      }
    } catch (e) {
      _showErrorDialog(context, '서버 요청 중 오류 발생: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}

class GlobalState with ChangeNotifier {
  static String _globalId = ""; // 전역 id 변수

  // 전역 id 값을 가져오는 getter
  static String get globalId => _globalId;

  // 전역 id 값을 설정하는 setter
  static void setGlobalId(String id) {
    _globalId = id;
    //notifyListeners(); // id 값 변경 시 리스너들에게 알림
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // GlobalKey 추가
  User? user;
  // 🔹 파일 업로드 함수 (서버와 동기화)
  Future<void> uploadAudioFile(File audioFile) async {
    final uri = Uri.parse(
        'https://ed8b-203-232-234-11.ngrok-free.app/api/speech-boards/record');

    var request = http.MultipartRequest('POST', uri);

    // SharedPreferences에서 accessToken 가져오기
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    // 헤더에 accessToken 추가
    if (accessToken != null) {
      request.headers['Authorization'] =
          'Bearer $accessToken';
    } else {
      print("토큰에 아무것도 안 담김");
    }

    // 오디오 파일을 서버에 첨부
    request.files.add(
      await http.MultipartFile.fromPath(
        'record',
        audioFile.path,
        contentType: MediaType('audio', 'm4a'),
      ),
    );
    _showCompletionDialog(audioFile.path);

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
          SnackBar(content: Text('파일 업로드 완료: ${jsonResponse["title"]}')),
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

      await uploadAudioFile(file); // 파일 서버에 업로드
    } else {
      print("파일 선택이 취소되었습니다.");
    }
  }

  Map<String, String> koreanToEnglish = {
    "공식적": "FORMAL",
    "비공식적": "INFORMAL",
    "정보전달": "INFORMATIVE",
    "보고": "REPORTING",
    "설득": "PERSUASIVE",
    "토론": "DEBATE",
    "소규모(~10명)": "SMALL",
    "중규모(~50명)": "MEDIUM",
    "대규모(50명~)": "LARGE",
    "일반 대중": "GENERAL",
    "관련 지식 보유자": "KNOWLEDGEABLE",
    "전문가": "EXPERT",
  };

  String _selectedAtmosphere = ''; // 분위기
  String _selectedPurpose = ''; // 목적
  String _selectedScale = ''; // 규모
  String _selectedAudience = ''; // 청중 수준
  TextEditingController _timeLimitController =
      TextEditingController(); // 제한 시간 입력
  TextEditingController _titleController = TextEditingController();

  void _showCompletionDialog(String filePath) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Column(
              children: [
                Container(
                  height: 5,
                  width: double.infinity,
                  color: Colors.black, // 상단 강조선
                ),
                SizedBox(height: 10),
                Text('발표 종류',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildTitleTextField('제목', _titleController),
                    _buildDropdown(
                        '📌 분위기', ['공식적', '비공식적'], _selectedAtmosphere,
                            (val) {
                          setState(() => _selectedAtmosphere = val);
                        }),
                    _buildDropdown(
                        '🎯 목적', ['정보 전달', '보고', '설득', '토론'], _selectedPurpose,
                            (val) {
                          setState(() => _selectedPurpose = val);
                        }),
                    _buildDropdown(
                        '👥 규모',
                        ['소규모 (~10명)', '중규모 (~50명)', '대규모 (50명 이상)'],
                        _selectedScale, (val) {
                      setState(() => _selectedScale = val);
                    }),
                    _buildDropdown('🎓 청중 수준', ['일반 대중', '관련 지식 보유자', '전문가'],
                        _selectedAudience, (val) {
                          setState(() => _selectedAudience = val);
                        }),
                    _buildTextField('⏳ 제한 시간 (선택)', _timeLimitController),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  if (_selectedAtmosphere.isNotEmpty &&
                      _selectedPurpose.isNotEmpty &&
                      _selectedScale.isNotEmpty &&
                      _selectedAudience.isNotEmpty) {
                    String atmosphereEng = koreanToEnglish[_selectedAtmosphere] ??
                        _selectedAtmosphere;
                    String purposeEng =
                        koreanToEnglish[_selectedPurpose] ?? _selectedPurpose;
                    String scaleEng =
                        koreanToEnglish[_selectedScale] ?? _selectedScale;
                    String audienceEng =
                        koreanToEnglish[_selectedAudience] ?? _selectedAudience;
                    // uploadAudioFile 호출 시 jwtToken 전달
                    await sendPresentationData(
                      atmosphereEng,
                      purposeEng,
                      scaleEng,
                      audienceEng,
                      _timeLimitController.text.isNotEmpty
                          ? int.parse(
                          _timeLimitController.text) // 🔹 String -> int 변환
                          : 0,
                    );
                    setState(() => _completeRecording(filePath));
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                        SnackBar(content: Text('모든 항목을 선택해주세요.')));
                  }
                },
                child: Text('확인',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
    }
  }

// 🔹 공통 드롭다운 위젯
  Widget _buildDropdown(String title, List<String> items, String selectedValue,
      Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: selectedValue.isEmpty ? null : selectedValue,
          hint: Text('선택하세요'),
          isExpanded: true,
          alignment: Alignment.center,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, textAlign: TextAlign.center),
            );
          }).toList(),
          onChanged: (newValue) => onChanged(newValue!),
        ),
        SizedBox(height: 10),
      ],
    );
  }

// 🔹 공통 텍스트 필드 위젯
  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: '시간을 입력하세요 (예: 30)',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildTitleTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: '제목을 입력하세요',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
          ),
          keyboardType: TextInputType.text,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  // 녹음 완료 후 카테고리와 함께 처리하는 함수
  void _completeRecording(String filePath) {
    String timeLimit =
        _timeLimitController.text.isNotEmpty ? _timeLimitController.text : '0';
    String title = _titleController.text;

    // 선택된 카테고리와 함께 녹음을 완료하는 처리
    print('제목: $title');
    print('분위기: $_selectedAtmosphere');
    print('목적: $_selectedPurpose');
    print('규모: $_selectedScale');
    print('청중 수준: $_selectedAudience');
    print('제한 시간: $timeLimit');
    print('파일 경로: $filePath');
  }

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  // 데이터를 받아오는 함수
  Future<void> _fetchUserInfo() async {
    ApiService apiService = ApiService();
    User? fetchedUser = await apiService.getUserInfo();

    if (fetchedUser != null) {
      setState(() {
        user = fetchedUser; // 받아온 데이터를 state에 저장
      });
    }
  }
  //마이페이지
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
                  user?.username ?? 'Loading...', // 실제 사용자 이름을 여기에 표시
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  user?.id ?? 'No ID', // 실제 사용자 ID를 여기에 표시
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
//스피치 보드
class SpeechBoardPage extends StatefulWidget {
  @override
  _SpeechBoardPageState createState() => _SpeechBoardPageState();
}

class _SpeechBoardPageState extends State<SpeechBoardPage> {
  late Future<void> _fetchAudioFuture;
  @override
  void initState() {
    super.initState();
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    _fetchAudioFuture = audioProvider.fetchAudioFiles(); // ID 전달
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('스피치 보드')),
      body: FutureBuilder<void>(
        future: _fetchAudioFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // 로딩 중
          }

          if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다. 다시 시도해주세요.'));
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      '생성 날짜: ${file.createdAt}',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FeedbackPage(speechBoardId: file.id), //id 넘김
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
    final url = 'https://ed8b-203-232-234-11.ngrok-free.app/api/speech-boards';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken'); // accessToken 가져오기

    if (token == null) {
      print('Access Token이 없습니다.');
      return;
    }

    _isLoading = true;
    notifyListeners(); // UI 갱신

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token', // Access Token 추가
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        if (responseBody.containsKey('data')) {
          List<dynamic> audioData = responseBody['data']; // 리스트 가져오기
          _audioList = audioData.map((item) => Audio.fromJson(item)).toList();
          notifyListeners();
        }
      } else {
        throw Exception('Failed to load audios: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('오디오 목록 불러오기 실패: $error');
    } finally {
      _isLoading = false;
      notifyListeners(); // 로딩 완료 알림
    }
  }

}

class Audio {
  final int id;
  final String userId;
  final String title;
  final String createdAt;

  Audio(
      {required this.id,
      required this.userId,
      required this.title,
      required this.createdAt});

  factory Audio.fromJson(Map<String, dynamic> json) {
    return Audio(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      createdAt: json['createdAt'],
    );
  }
}

class FeedbackPage extends StatefulWidget {
  final int speechBoardId; // speech_board_id를 받음

  const FeedbackPage(
      {super.key, required this.speechBoardId});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  String originalStt = "";
  String conclusion = "";
  bool isLoading = true; // 데이터 로딩 상태
  int score = 0;
  List<String> topics = [];

  @override
  void initState() {
    super.initState();
    fetchTextAndFeedback(widget.speechBoardId); // 변환된 텍스트 & 피드백 가져오기

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

    playAudio(widget.speechBoardId); // 자동으로 오디오 재생
  }

  // 변환된 텍스트와 피드백 가져오기
  Future<void> fetchTextAndFeedback(int speechBoardId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken'); // accessToken 가져오기
      final response = await http.get(
        Uri.parse(
            "https://ed8b-203-232-234-11.ngrok-free.app/api/speech-boards/$speechBoardId/feedback"),
        headers: {
          'Authorization': 'Bearer $accessToken', // GET 요청에 Authorization 헤더 추가
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body); //텍스트

        setState(() {
          originalStt = data['data']['originalStt'] ?? "";
          score = data['data']['score'] ?? 0;
          conclusion = data['data']['conclusion'] ?? "";
          topics = List<String>.from(data['data']['topics'] ?? []);
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
  Future<void> playAudio(int speechBoardId) async {
    try {
      // 백엔드에서 GET 요청으로 record 데이터 받아오기
      final response = await http.get(
        Uri.parse("https://ed8b-203-232-234-11.ngrok-free.app/api/speech-boards/$speechBoardId/record"), // 실제 record 데이터를 받아오는 URL로 변경
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String audioPath = data['record']; // 백엔드에서 반환하는 오디오 경로를 받음

        // audioPlayer에 오디오 경로 설정
        await audioPlayer.stop();
        await audioPlayer.setSourceUrl(audioPath);
        await audioPlayer.resume();

        setState(() {
          isPlaying = true;
        });
      } else {
        print("오디오 경로를 가져오는 데 실패했습니다.");
      }
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
      appBar: AppBar(
        title: Text('스피치 피드백'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.search),
            onSelected: (value) {
              print("$value 선택");
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: '제목 수정',
                  child: Text("제목 수정"),
                ),
                PopupMenuItem(
                  value: '텍스트 수정',
                  child: Text("텍스트 수정"),
                ),
              ];
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator()) // 데이터 로딩 중
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "점수 : $score",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
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
                    child: Text(originalStt, style: TextStyle(fontSize: 16)),
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
                    child: Text(conclusion, style: TextStyle(fontSize: 16)),
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
                              isPlaying ? Icons.pause : Icons.play_arrow,
                            ),
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

/*
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
      final response = await http.get(Uri.parse(
          "https://ed8b-203-232-234-11.ngrok-free.app/api/speech-boards"));
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
*/

class CoachingPlanPage extends StatefulWidget {
  @override
  _CoachingPlanPage createState() => _CoachingPlanPage();
}

class _CoachingPlanPage extends State<CoachingPlanPage> {
  List<Map<String, dynamic>> topics = [];
  List<String> topicList = [];

  @override
  void initState() {
    super.initState();
    fetchTopics();
  }

  Future<void> fetchTopics() async {
    final response = await http.get(Uri.parse(
        'https://ed8b-203-232-234-11.ngrok-free.app/api/speech-coachings'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        topics = List<Map<String, dynamic>>.from(jsonResponse['data'][0]['topics']);
      });
    } else {
      throw Exception('Failed to load topics');
    }
  }

  // topicId를 전달하는 함수
  void _navigateToRecording(int selectedTopicId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => minRecordingPage(topicId: selectedTopicId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('스피치 코칭')),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '스피치 코칭',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              '3분 스피치',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 10),
            Expanded(
              child: topics.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  // 각 topic 문자열을 공백을 기준으로 분할
                  topicList = topics[index]['topic'].split(' ');

                  return GestureDetector(
                    onTap: () {
                      int selectedTopicId = topics[index]['topicId'];
                      _navigateToRecording(selectedTopicId); // topicId를 전달
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '신규 스피치 ${index + 1}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: topicList
                                  .map((topic) => Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  topic,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
      if (!audioFile.existsSync()) return 'File does not exist';

      final directory = await getApplicationDocumentsDirectory();
      final newDir = Directory(p.join(directory.path, 'recordings'));
      if (!await newDir.exists()) await newDir.create(recursive: true);

      final newFile = File(p.join(
          newDir.path, 'audio_${DateTime.now().millisecondsSinceEpoch}.mp4'));
      await audioFile.copy(newFile.path);

      // SharedPreferences에서 jwtToken 가져오기
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jwtToken = prefs.getString('jwtToken');
      if (jwtToken == null) {
        return 'JWT Token is missing';
      }

      return newFile.path;
    } catch (e) {
      print('녹음 저장 중 오류 발생: $e');
      return 'Error: $e';
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Map<String, String> koreanToEnglish = {
    "공식적": "FORMAL",
    "비공식적": "INFORMAL",
    "정보전달": "INFORMATIVE",
    "보고": "REPORTING",
    "설득": "PERSUASIVE",
    "토론": "DEBATE",
    "소규모(~10명)": "SMALL",
    "중규모(~50명)": "MEDIUM",
    "대규모(50명~)": "LARGE",
    "일반 대중": "GENERAL",
    "관련 지식 보유자": "KNOWLEDGEABLE",
    "전문가": "EXPERT",
  };

  String _selectedAtmosphere = ''; // 분위기
  String _selectedPurpose = ''; // 목적
  String _selectedScale = ''; // 규모
  String _selectedAudience = ''; // 청중 수준
  TextEditingController _timeLimitController =
      TextEditingController(); // 제한 시간 입력
  TextEditingController _titleController = TextEditingController();

  void _showCompletionDialog(String filePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Column(
            children: [
              Container(
                height: 5,
                width: double.infinity,
                color: Colors.black, // 상단 강조선
              ),
              SizedBox(height: 10),
              Text('발표 종류',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildTitleTextField('제목', _titleController),
                  _buildDropdown('📌 분위기', ['공식적', '비공식적'], _selectedAtmosphere,
                      (val) {
                    setState(() => _selectedAtmosphere = val);
                  }),
                  _buildDropdown(
                      '🎯 목적', ['정보 전달', '보고', '설득', '토론'], _selectedPurpose,
                      (val) {
                    setState(() => _selectedPurpose = val);
                  }),
                  _buildDropdown(
                      '👥 규모',
                      ['소규모 (~10명)', '중규모 (~50명)', '대규모 (50명 이상)'],
                      _selectedScale, (val) {
                    setState(() => _selectedScale = val);
                  }),
                  _buildDropdown('🎓 청중 수준', ['일반 대중', '관련 지식 보유자', '전문가'],
                      _selectedAudience, (val) {
                    setState(() => _selectedAudience = val);
                  }),
                  _buildTextField('⏳ 제한 시간 (선택)', _timeLimitController),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                if (_selectedAtmosphere.isNotEmpty &&
                    _selectedPurpose.isNotEmpty &&
                    _selectedScale.isNotEmpty &&
                    _selectedAudience.isNotEmpty) {
                  String atmosphereEng = koreanToEnglish[_selectedAtmosphere] ??
                      _selectedAtmosphere;
                  String purposeEng =
                      koreanToEnglish[_selectedPurpose] ?? _selectedPurpose;
                  String scaleEng =
                      koreanToEnglish[_selectedScale] ?? _selectedScale;
                  String audienceEng =
                      koreanToEnglish[_selectedAudience] ?? _selectedAudience;
                  // uploadAudioFile 호출 시 jwtToken 전달
                  await sendPresentationData(
                    atmosphereEng,
                    purposeEng,
                    scaleEng,
                    audienceEng,
                    _timeLimitController.text.isNotEmpty
                        ? int.parse(
                            _timeLimitController.text) // 🔹 String -> int 변환
                        : 0,
                  );
                  setState(() => _completeRecording(filePath)); //print, gohome
                  Navigator.pop(context);
                  _goHomePage();
                } else {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('모든 항목을 선택해주세요.')));
                }
              },
              child: Text('확인',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

// 🔹 공통 드롭다운 위젯
  Widget _buildDropdown(String title, List<String> items, String selectedValue,
      Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: selectedValue.isEmpty ? null : selectedValue,
          hint: Text('선택하세요'),
          isExpanded: true,
          alignment: Alignment.center,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, textAlign: TextAlign.center),
            );
          }).toList(),
          onChanged: (newValue) => onChanged(newValue!),
        ),
        SizedBox(height: 10),
      ],
    );
  }

// 🔹 공통 텍스트 필드 위젯
  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: '시간을 입력하세요 (예: 30)',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildTitleTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: '제목을 입력하세요',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
          ),
          keyboardType: TextInputType.text,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  // 녹음 완료 후 카테고리와 함께 처리하는 함수
  void _completeRecording(String filePath) {
    String timeLimit =
        _timeLimitController.text.isNotEmpty ? _timeLimitController.text : '0';
    String title = _titleController.text;

    // 선택된 카테고리와 함께 녹음을 완료하는 처리
    print('제목: $title');
    print('분위기: $_selectedAtmosphere');
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

class minRecordingPage extends StatefulWidget {
  final int topicId;

  minRecordingPage({required this.topicId});

  @override
  _minRecordingPageState createState() => _minRecordingPageState();
}

class _minRecordingPageState extends State<minRecordingPage> {
  sound.FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  Duration _remainingDuration = Duration(minutes: 3); // 3분 카운트다운
  Timer? _timer;
  late String _filePath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    _recorder = sound.FlutterSoundRecorder();
    await _recorder!.openRecorder();
    _startRecording();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder?.closeRecorder();
    super.dispose();
  }

  // 녹음 시작 및 카운트다운
  Future<void> _startRecording() async {
    final directory = await getApplicationDocumentsDirectory();
    _filePath = p.join(directory.path, 'audio_${DateTime.now().millisecondsSinceEpoch}.aac');

    setState(() {
      _isRecording = true;
      _remainingDuration = Duration(minutes: 3); // 초기화
    });

    await _recorder!.startRecorder(toFile: _filePath, codec: sound.Codec.aacMP4);

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingDuration.inSeconds > 0) {
        setState(() {
          _remainingDuration -= Duration(seconds: 1);
        });
      } else {
        _stopRecording();
      }
    });
  }

  // 일시 정지/재개
  Future<void> _pauseRecording() async {
    if (_recorder!.isRecording) {
      await _recorder!.pauseRecorder();
      setState(() => _isRecording = false);
    } else if (_recorder!.isPaused) {
      await _recorder!.resumeRecorder();
      setState(() => _isRecording = true);
    }
  }

  // 녹음 정지
  Future<void> _stopRecording() async {
    if (_recorder != null) {
      await _recorder!.stopRecorder();
    }
    _timer?.cancel();
    setState(() => _isRecording = false);
    Navigator.pop(context);
  }

  // 업로드 함수
  Future<void> _uploadRecording(int topicId) async {
    try {
      File file = File(_filePath);
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
      if (accessToken == null) {
        // 토큰이 없으면 에러 처리
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('토큰 없음'),
          backgroundColor: Colors.red,
        ));
        return;
      }

      final url = Uri.parse('https://ed8b-203-232-234-11.ngrok-free.app/api/topics/$topicId/speech-coachings/record');

      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $accessToken'
        ..files.add(await http.MultipartFile.fromPath(
          'record',
          file.path,
          contentType: MediaType('audio', 'x-m4a'), // m4a 형식 지정
        ));

      var response = await request.send();

      if (response.statusCode == 200) {
        // 응답 스트림을 문자열로 변환하여 JSON 파싱
        String responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> responseJson = json.decode(responseBody);

        // JSON에서 'speechCoachingId'를 추출하고 정수형으로 변환
        int speechCoachingId = responseJson['speechCoachingId'];

        // 업로드 후 페이지 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CoachingFeedbackPage(speechCoachingId: speechCoachingId)), // 업로드 후 이동할 페이지
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('코칭 업로드 실패'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('코칭 업로드중 오류: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // 시간을 "MM:SS" 형식으로 포맷
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('3분 녹음')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _formatDuration(_remainingDuration),
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
                  onPressed: () async {
                    await _uploadRecording(widget.topicId); // 업로드 함수 호출
                  },
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
/*
class minRecordingPage extends StatefulWidget {
  final String topicId;

  minRecordingPage({required this.topicId});
  @override
  _minRecordingPageState createState() => _minRecordingPageState();
}

class _minRecordingPageState extends State<minRecordingPage> {
  sound.FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  Duration _remainingDuration = Duration(minutes: 3);
  Timer? _timer;
  late String _filePath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    _recorder = sound.FlutterSoundRecorder();
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
      _remainingDuration = Duration(minutes: 3);
    });

    await _recorder!
        .startRecorder(toFile: _filePath, codec: sound.Codec.aacMP4);

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingDuration.inSeconds > 0) {
        setState(() {
          _remainingDuration -= Duration(seconds: 1);
        });
      } else {
        _stopRecording();
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
    _timer?.cancel();
    setState(() => _isRecording = false);
    Navigator.pop(context);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('3분 녹음')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _formatDuration(_remainingDuration),
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
}*/
class CoachingFeedbackPage extends StatefulWidget {
  final int speechCoachingId; // speech_board_id를 받음

  const CoachingFeedbackPage(
      {super.key, required this.speechCoachingId});

  @override
  State<CoachingFeedbackPage> createState() => _CoachingFeedbackPageState();
}

class _CoachingFeedbackPageState extends State<CoachingFeedbackPage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  String originalStt = "";
  String conclusion = "";
  bool isLoading = true; // 데이터 로딩 상태
  int score = 0;
  List<String> topics = [];

  @override
  void initState() {
    super.initState();
    fetchTextAndFeedback(widget.speechCoachingId); // 변환된 텍스트 & 피드백 가져오기

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

    playAudio(widget.speechCoachingId); // 자동으로 오디오 재생
  }

  // 변환된 텍스트와 피드백 가져오기
  Future<void> fetchTextAndFeedback(int speechCoachingId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken'); // accessToken 가져오기
      final response = await http.get(
        Uri.parse(
            "https://ed8b-203-232-234-11.ngrok-free.app/api/speech-coachings/$speechCoachingId/feedback"),
        headers: {
          'Authorization': 'Bearer $accessToken', // GET 요청에 Authorization 헤더 추가
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body); //텍스트

        setState(() {
          originalStt = data['data']['originalStt'] ?? "";
          score = data['data']['score'] ?? 0;
          conclusion = data['data']['conclusion'] ?? "";
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
  Future<void> playAudio(int speechCoachingId) async {
    try {
      // 백엔드에서 GET 요청으로 record 데이터 받아오기
      final response = await http.get(
        Uri.parse("https://ed8b-203-232-234-11.ngrok-free.app/api/speech-coachings/$speechCoachingId/record"), // 실제 record 데이터를 받아오는 URL로 변경
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String audioPath = data['record']; // 백엔드에서 반환하는 오디오 경로를 받음

        // audioPlayer에 오디오 경로 설정
        await audioPlayer.stop();
        await audioPlayer.setSourceUrl(audioPath);
        await audioPlayer.resume();

        setState(() {
          isPlaying = true;
        });
      } else {
        print("오디오 경로를 가져오는 데 실패했습니다.");
      }
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
      appBar: AppBar(
        title: Text('스피치코칭 피드백'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.search),
            onSelected: (value) {
              print("$value 선택");
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: '제목 수정',
                  child: Text("제목 수정"),
                ),
                PopupMenuItem(
                  value: '텍스트 수정',
                  child: Text("텍스트 수정"),
                ),
              ];
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator()) // 데이터 로딩 중
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "점수 : $score",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
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
              child: Text(originalStt, style: TextStyle(fontSize: 16)),
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
              child: Text(conclusion, style: TextStyle(fontSize: 16)),
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
                        isPlaying ? Icons.pause : Icons.play_arrow,
                      ),
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

//벡엔드로 메타정보 전송
Future<void> sendPresentationData(String atmosphere, String purpose,
    String scale, String audience, int deadline) async {
  var uri = Uri.parse(
      "https://ed8b-203-232-234-11.ngrok-free.app/api/speech-boards/record"); // JSON 데이터 전송 URL
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString('accessToken');

  var body = {
    "atmosphere": atmosphere,
    "purpose": purpose,
    "scale": scale,
    "audience": audience,
    "deadline": deadline, // 🔹 int로 보낼 경우
  };

  var response = await http.post(
    uri,
    headers: {
      'Authorization': 'Bearer $accessToken',
      "Content-Type": "application/json"
    },
    body: json.encode(body), //jsonEncode
  );

  if (response.statusCode == 200) {
    debugPrint("데이터 전송 성공!");
  } else {
    debugPrint("전송 실패: ${response.statusCode}");
  }
}

//백엔드에서 파일 목록 가져오기
/*Future<List<AudioFile>> fetchAudioFiles() async {
  final response = await http.get(
      Uri.parse('https://ed8b-203-232-234-11.ngrok-free.app/api/speech-boards'));
  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((item) => AudioFile.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load audio files');
  }
}
*/
class AudioFile {
  final String speechBoardId;
  final String file;
  final String userId;
  final String title;
  final List<String> categories;

  AudioFile({
    required this.speechBoardId,
    required this.file,
    required this.userId,
    required this.title,
    required this.categories,
  });

  factory AudioFile.fromJson(Map<String, dynamic> json) {
    return AudioFile(
      speechBoardId: _generateSpeechBoardId(),
      file: json['file'],
      userId: json['userId'],
      title: json['title'],
      categories: List<String>.from(json['category']),
    );
  }

  static String _generateSpeechBoardId() {
    var timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return 'speech_$timestamp';
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
