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
      if (response.user != null) {
        final userId = response.user!.id;
        await _supabase.from('profiles').insert({
          'id': userId,
          'full_name': '$firstName $lastName',
          'role': 'Member',
        });
      }
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

  static Future<Map<String, dynamic>?> getProfile(String userId) async {
    final profileResponse = await _supabase
        .from('profiles')
        .select('full_name, role')
        .eq('id', userId)
        .maybeSingle();

    if (profileResponse == null) return null;

    final memberResponse = await _supabase
        .from('members')
        .select('phone, address')
        .eq('profile_id', userId)
        .maybeSingle();

    final Map<String, dynamic> data = {...profileResponse};
    if (memberResponse != null) {
      data.addAll(memberResponse);
    }
    return data;
  }

  static Future<void> updateMemberProfile({
    required String userId,
    required String fullName,
    required String phone,
    required String address,
  }) async {
    // Update profiles table
    await _supabase
        .from('profiles')
        .update({'full_name': fullName})
        .eq('id', userId);

    // Check if member record exists
    final member = await _supabase
        .from('members')
        .select()
        .eq('profile_id', userId)
        .maybeSingle();

    if (member != null) {
      await _supabase
          .from('members')
          .update({'phone': phone, 'address': address})
          .eq('profile_id', userId);
    } else {
      final user = _supabase.auth.currentUser;
      await _supabase.from('members').insert({
        'profile_id': userId,
        'email': user?.email,
        'phone': phone,
        'address': address,
      });
    }
  }
}
