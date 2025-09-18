import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/token_manager.dart';

const String baseUrl = 'https://d1q3s3lne7ucem.cloudfront.net';
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
    required List<String> followedChannels,
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
      },
      "followed_channels": followedChannels
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
    String? userId,
    List<String>? interests,
    List<String>? deliveryDays,
    String? format,
    String? deliveryTime,
    List<String>? followedChannels
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/auth/update-profile');
      final headers = <String, String>{
        ...baseHeaders,
        ...TokenManager.getAuthHeaders(),
      };

      Map<String, dynamic> requestBody = {
        "delivery_schedule": {}
      };

      if(userId != null){
        requestBody["user_id"] = userId;
      }
      if(interests != null){
        requestBody["interests"] = interests;
      }
      if(format != null){
        requestBody["format"] = format;
      }
      if(deliveryDays != null){
        requestBody["delivery_schedule"]["delivery_days"] = deliveryDays;
      }
      if(deliveryTime != null){
        requestBody["delivery_schedule"]["delivery_time"] = deliveryTime;
      }
      if(followedChannels != null){
        requestBody["followed_channels"] = followedChannels;
      }
      final body = json.encode(requestBody);

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
  // TODO: esse endpoint nao existe mais no backend
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
      final url = Uri.parse('$baseUrl/api/logout');
      
      final headers = <String, String>{
        ...baseHeaders,
        ...TokenManager.getAuthHeaders(),
      };

      final response = await http.post(url, headers: headers);
      
      // Clear local token regardless of server response
      await TokenManager.clearAuthData();
      
      if (response.statusCode == 200) {
        print('AUTH: User logged out successfully from server');
      } else {
        print('AUTH: Server logout failed (${response.statusCode}), but local token cleared');
      }
    } catch (e) {
      // Still clear local token even if server call fails
      await TokenManager.clearAuthData();
      print('AUTH: Logout completed (with error): $e');
    }
  }

  // Generate a new newsletter for the user
  static Future<Map<String, dynamic>> generateNewsletter({String? topic}) async {
    try {
      String urlPath = '/api/newsletter/generate';
      if (topic != null && topic.isNotEmpty) {
        urlPath += '?topic=$topic';
      }
      final url = Uri.parse('$baseUrl$urlPath');
      
      final headers = <String, String>{
        ...baseHeaders,
        ...TokenManager.getAuthHeaders(),
      };

      final response = await http.post(url, headers: headers);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to generate newsletter: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error generating newsletter: $e');
    }
  }

  // Get all user's newsletters
  static Future<Map<String, dynamic>> getNewsletters({
    bool saved = false,
    String topic = ''
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/newsletters?saved=$saved&topic=$topic');
      
      final headers = <String, String>{
        ...baseHeaders,
        ...TokenManager.getAuthHeaders(),
      };

      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get newsletters: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting newsletters: $e');
    }
  }

  // Get articles for a specific newsletter
  static Future<Map<String, dynamic>> getNewsletterArticles(String newsletterId) async {
    try {
      final url = Uri.parse('$baseUrl/api/newsletters/$newsletterId');
      
      final headers = <String, String>{
        ...baseHeaders,
        ...TokenManager.getAuthHeaders(),
      };

      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get newsletter articles: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting newsletter articles: $e');
    }
  }

  // Get all available topics
  static Future<Map<String, dynamic>> getTopics() async {
    try {
      final url = Uri.parse('$baseUrl/api/topics/detailed');
      
      final headers = <String, String>{
        ...baseHeaders,
        ...TokenManager.getAuthHeaders(),
      };

      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get topics: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting topics: $e');
    }
  }

  // Get newsletter topics count
  static Future<Map<String, dynamic>> getNewsletterTopicsCount() async {
    try {
      final url = Uri.parse('$baseUrl/api/newsletters/topics-count');
      
      final headers = <String, String>{
        ...baseHeaders,
        ...TokenManager.getAuthHeaders(),
      };

      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get newsletter topics count: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting newsletter topics count: $e');
    }
  }

  // Get all available news sources
  static Future<Map<String, dynamic>> getSources() async {
    try {
      final url = Uri.parse('$baseUrl/api/sources');
      
      final headers = <String, String>{
        ...baseHeaders,
        ...TokenManager.getAuthHeaders(),
      };

      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get sources: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting sources: $e');
    }
  }

  // Toggle save status for a newsletter
  static Future<Map<String, dynamic>> toggleNewsletterSave(String newsletterId) async {
    try {
      final url = Uri.parse('$baseUrl/api/newsletters/$newsletterId/toggle-save');
      
      final headers = <String, String>{
        ...baseHeaders,
        ...TokenManager.getAuthHeaders(),
      };

      final response = await http.post(url, headers: headers);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to toggle newsletter save: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error toggling newsletter save: $e');
    }
  }
}
