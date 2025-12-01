import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_project/feature/authentication/model/user_model.dart';
import 'package:library_project/feature/authentication/viewmodel/auth_state.dart';
import 'package:library_project/service/subapase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthNotifier extends StateNotifier<AuthenticationState> {
  AuthNotifier() : super(_initialState()) {
    _checkAuthStatus();
  }

  static AuthenticationState _initialState() {
    // Check if user is already signed in
    final currentUser = SupabaseService.getCurrentUser();
    if (currentUser != null) {
      final userMetadata = currentUser.userMetadata;
      return AuthenticationLoaded(
        UserModel(
          name: userMetadata?['full_name'] ?? currentUser.email ?? '',
          email: currentUser.email ?? '',
          password: '', // Don't store password in state
          phone: userMetadata?['phone'] ?? '',
          role: 'Member',
        ),
      );
    }
    return AuthenticationInitialState();
  }

  Future<void> _checkAuthStatus() async {
    final currentUser = SupabaseService.getCurrentUser();
    if (currentUser != null) {
      final userMetadata = currentUser.userMetadata;
      final profile = await SupabaseService.getProfile(currentUser.id);
      final role = (profile?['role'] as String?) ?? 'Member';
      final fullName =
          (profile?['full_name'] as String?) ??
          userMetadata?['full_name'] ??
          currentUser.email ??
          '';

      state = AuthenticationLoaded(
        UserModel(
          name: fullName,
          email: currentUser.email ?? '',
          password: '',
          phone: userMetadata?['phone'] ?? '',
          role: role,
        ),
      );
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    state = AuthenticationLoading();

    try {
      final response = await SupabaseService.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      if (response.user != null) {
        final userMetadata = response.user!.userMetadata;
        final profile = await SupabaseService.getProfile(response.user!.id);
        final role = (profile?['role'] as String?) ?? 'Member';
        final fullName =
            (profile?['full_name'] as String?) ??
            userMetadata?['full_name'] ??
            '$firstName $lastName';
        state = AuthenticationLoaded(
          UserModel(
            name: fullName,
            email: email,
            password: '', // Don't store password
            phone: userMetadata?['phone'] ?? '',
            role: role,
          ),
        );
      } else {
        state = AuthenticationError(
          'Failed to create account. Please try again.',
        );
      }
    } on AuthException catch (e) {
      state = AuthenticationError(e.message);
    } catch (e) {
      state = AuthenticationError(
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    state = AuthenticationLoading();

    try {
      final response = await SupabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userMetadata = response.user!.userMetadata;
        final profile = await SupabaseService.getProfile(response.user!.id);
        final role = (profile?['role'] as String?) ?? 'Member';
        final fullName =
            (profile?['full_name'] as String?) ??
            userMetadata?['full_name'] ??
            response.user!.email ??
            '';
        state = AuthenticationLoaded(
          UserModel(
            name: fullName,
            email: email,
            password: '', // Don't store password
            phone: userMetadata?['phone'] ?? '',
            role: role,
          ),
        );
      } else {
        state = AuthenticationError('Failed to sign in. Please try again.');
      }
    } on AuthException catch (e) {
      state = AuthenticationError(e.message);
    } catch (e) {
      state = AuthenticationError(
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  Future<void> signOut() async {
    state = AuthenticationLoading();

    try {
      await SupabaseService.signOut();
      state = AuthenticationInitialState();
    } catch (e) {
      state = AuthenticationError('Failed to sign out. Please try again.');
    }
  }
}

// Provider for AuthNotifier
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthenticationState>((ref) {
      return AuthNotifier();
    });
