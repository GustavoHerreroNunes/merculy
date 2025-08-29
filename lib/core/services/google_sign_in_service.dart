import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: dotenv.env['GOOGLE_CLIENT_ID'],
    scopes: [
      'email',
      'profile',
    ],
  );

  static Future<void> initializeGoogleSignIn() async {
    try {
      // Initialize the plugin
      await _googleSignIn.isSignedIn();
    } on PlatformException catch (e) {
      print('Error initializing Google Sign-In: $e');
      rethrow;
    }
  }

  static Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      // Ensure initialization
      await initializeGoogleSignIn();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      if (account != null) {
        // Get authentication details
        final GoogleSignInAuthentication googleAuth = await account.authentication;
        
        // You can use googleAuth.accessToken and googleAuth.idToken
        print('Sign in successful: ${account.email}');
        return account;
      }
      
      return null;
    } on PlatformException catch (e) {
      print('Platform exception during sign in: $e');
      throw Exception('Failed to sign in with Google: ${e.message}');
    } catch (e) {
      print('Error during Google sign in: $e');
      throw Exception('An unexpected error occurred during sign in');
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  static Future<GoogleSignInAccount?> getCurrentUser() async {
    try {
      await initializeGoogleSignIn();
      return _googleSignIn.currentUser;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
}
