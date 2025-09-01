import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  
  static String? _currentToken;
  static String? _currentUserId;
  static String? _currentUserEmail;
  static String? _currentUserName;

  // Initialize token manager - call this at app startup
  static Future<void> initialize() async {
    await _loadTokenFromStorage();
  }

  // Save token and user data to device storage
  static Future<void> saveAuthData({
    required String token,
    required String userId,
    required String email,
    required String name,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userIdKey, userId);
      await prefs.setString(_userEmailKey, email);
      await prefs.setString(_userNameKey, name);
      
      // Update in-memory cache
      _currentToken = token;
      _currentUserId = userId;
      _currentUserEmail = email;
      _currentUserName = name;
      
      print('AUTH: Token and user data saved successfully');
    } catch (e) {
      print('AUTH: Error saving token: $e');
    }
  }

  // Get current auth token
  static String? get token => _currentToken;
  static String? get userId => _currentUserId;
  static String? get userEmail => _currentUserEmail;
  static String? get userName => _currentUserName;

  // Check if user is logged in (has a token)
  static bool get isLoggedIn => _currentToken != null && _currentToken!.isNotEmpty;

  // Load token from storage
  static Future<void> _loadTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _currentToken = prefs.getString(_tokenKey);
      _currentUserId = prefs.getString(_userIdKey);
      _currentUserEmail = prefs.getString(_userEmailKey);
      _currentUserName = prefs.getString(_userNameKey);
      
      if (isLoggedIn) {
        print('AUTH: Token loaded from storage');
      } else {
        print('AUTH: No token found in storage');
      }
    } catch (e) {
      print('AUTH: Error loading token from storage: $e');
    }
  }

  // Clear all auth data (logout)
  static Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.remove(_tokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userNameKey);
      
      // Clear in-memory cache
      _currentToken = null;
      _currentUserId = null;
      _currentUserEmail = null;
      _currentUserName = null;
      
      print('AUTH: Auth data cleared successfully');
    } catch (e) {
      print('AUTH: Error clearing auth data: $e');
    }
  }

  // Get authorization headers for API requests
  static Map<String, String> getAuthHeaders() {
    if (!isLoggedIn) {
      return {};
    }
    
    return {
      'Authorization': 'Bearer $_currentToken',
    };
  }
}
