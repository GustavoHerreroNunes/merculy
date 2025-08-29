import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://merculy-app-hehte6a4ffc5hqeh.brazilsouth-01.azurewebsites.net';
const Map<String, String> baseHeaders = {'Content-Type': 'application/json; charset=utf-8'};

class BackendApiManager {
  
  Future<Map<String, dynamic>?> registerUser({
    required String email,
    required String name,
    required String password,
    required List<String> interests,
    required String newsletterFormat,
    required List<String> deliveryDays,
    required String deliveryTime,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/register');
    final headers = baseHeaders;
    final body = jsonEncode({
      "email": email,
      "name": name,
      "password": password,
      "interests": interests,
      "newsletter_format": newsletterFormat,
      "delivery_schedule": {
        "days": deliveryDays,
        "time": deliveryTime
      }
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to register user: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during registration: $e');
    }
  }

  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    final headers = baseHeaders;
    final body = jsonEncode({
      "email": email,
      "password": password
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to login: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during login: $e');
    }
  }

  static Future<Map<String, dynamic>> googleLogin(String googleToken) async {
    try {
      final url = Uri.parse('$baseUrl/api/auth/google-login');
      final headers = baseHeaders;
      
      final body = json.encode({
        'token': googleToken,
      });

      print('[step 2.1]');

      final response = await http.post(url, headers: headers, body: body);
      
      if (response.statusCode == 200) {
        print('[step 2.2]');
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print('[step 2.3]');
        throw Exception('Failed to login with Google: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during Google login: $e');
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required List<String> interests,
    required List<String> deliveryDays,
    required String format,
    required String deliveryTime,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/update-profile');
      final headers = baseHeaders;
      
      final body = json.encode({
        'user_id': userId,
        'interests': interests,
        'delivery_days': deliveryDays,
        'format': format,
        'delivery_time': deliveryTime,
      });

      final response = await http.put(url, headers: headers, body: body);
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update profile: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during profile update: $e');
    }
  }
}
