import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Sign up a new user with email and password
  /// Includes metadata: first_name and last_name
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'full_name': '$firstName $lastName',
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in an existing user with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out the current user
  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Get the current user session
  static User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  /// Check if user is signed in
  static bool isSignedIn() {
    return _supabase.auth.currentUser != null;
  }
}
