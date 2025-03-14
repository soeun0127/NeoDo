import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user.dart'; // 위에서 정의한 User 클래스를 import

class ApiService {
  Future<User?> getUserInfo() async {
    final url = Uri.parse(
        'https://76db-1-230-133-117.ngrok-free.app/api/users/my-page'); // 실제 API 엔드포인트로 변경
    final response = await http.get(url);

    // 상태 코드가 200인지 확인
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      // 응답 데이터가 제대로 왔는지 확인
      if (responseData['data'] != null) {
        final data = responseData['data']; // data 변수 사용

        // User 객체 반환
        return User.fromJson(data); // data를 User.fromJson에 넘겨줌
      } else {
        print('No data found in response');
        return null;
      }
    } else {
      print("Failed to load user info: ${response.body}");
      return null;
    }
  }
}
