import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/token_manager.dart';

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
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Save JWT token if present
        if (responseData.containsKey('token')) {
          await TokenManager.saveAuthData(
            token: responseData['token'],
            userId: responseData['user']?['id'] ?? '',
            email: responseData['user']?['email'] ?? email,
            name: responseData['user']?['name'] ?? name,
          );
        }
        
        return responseData;
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
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Save JWT token if present
        if (responseData.containsKey('token')) {
          await TokenManager.saveAuthData(
            token: responseData['token'],
            userId: responseData['user']?['id'] ?? '',
            email: responseData['user']?['email'] ?? email,
            name: responseData['user']?['name'] ?? '',
          );
        }
        
        return responseData;
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
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        
        // Save JWT token if present
        if (responseData.containsKey('token')) {
          await TokenManager.saveAuthData(
            token: responseData['token'],
            userId: responseData['user']?['id'] ?? '',
            email: responseData['user']?['email'] ?? '',
            name: responseData['user']?['name'] ?? '',
          );
        }
        
        return responseData;
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
      final url = Uri.parse('$baseUrl/api/auth/update-profile');
      final headers = <String, String>{
        ...baseHeaders,
        ...TokenManager.getAuthHeaders(),
      };
      
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

  // Get current user information
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final url = Uri.parse('$baseUrl/api/auth/me');
      print("[DEBUG - Me]");
      
      final headers = <String, String>{
        ...baseHeaders,
        ...TokenManager.getAuthHeaders(),
      };

      print("Headers with auth: $headers");

      final response = await http.get(url, headers: headers);
      
      print("After request");

      if (response.statusCode == 200) {
        print(json.decode(response.body) as Map<String, dynamic>);
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print("[ERROR]");
        print(response.body);
        throw Exception('Failed to get user info: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("[ERROR]");
      print(e);
      throw Exception('Error getting user info: $e');
    }
  }

  // Update user basic information (name, email)
  static Future<Map<String, dynamic>> updateUser({
    required String name,
    required String email,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/auth/update-profile');
      
      final headers = <String, String>{
        ...baseHeaders,
        ...TokenManager.getAuthHeaders(),
      };
      
      final body = json.encode({
        'name': name,
        'email': email,
      });

      final response = await http.put(url, headers: headers, body: body);
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update user: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  // Change user password
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/auth/change-password');
      
      final headers = <String, String>{
        ...baseHeaders,
        ...TokenManager.getAuthHeaders(),
      };
      
      final body = json.encode({
        'current_password': currentPassword,
        'new_password': newPassword,
      });

      final response = await http.put(url, headers: headers, body: body);
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to change password: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error changing password: $e');
    }
  }

  // Debug endpoint to get session information
  static Future<Map<String, dynamic>> getSessionInfo() async {
    try {
      final url = Uri.parse('$baseUrl/api/debug/session-info');
      
      final headers = <String, String>{
        ...baseHeaders,
        ...TokenManager.getAuthHeaders(),
      };

      final response = await http.get(url, headers: headers);
      
      print('DEBUG - Session info response status: ${response.statusCode}');
      print('DEBUG - Session info response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get session info: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting session info: $e');
    }
  }

  // Logout user
  static Future<void> logout() async {
    try {
      // Call logout endpoint if available
      // final url = Uri.parse('$baseUrl/api/auth/logout');
      // final response = await http.post(url, headers: {...baseHeaders, ...TokenManager.getAuthHeaders()});
      
      // Clear local token regardless of server response
      await TokenManager.clearAuthData();
      print('AUTH: User logged out successfully');
    } catch (e) {
      // Still clear local token even if server call fails
      await TokenManager.clearAuthData();
      print('AUTH: Logout completed (with error): $e');
    }
  }
}
