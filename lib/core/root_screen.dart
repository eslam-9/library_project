import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_project/feature/admin/view/admin_main_screen.dart';
import 'package:library_project/feature/authentication/view/login.dart';
import 'package:library_project/feature/authentication/viewmodel/auth_notifier.dart';
import 'package:library_project/feature/authentication/viewmodel/auth_state.dart';
import 'package:library_project/feature/member/view/member_main_screen.dart';
import 'package:library_project/feature/onboarding/view/onboardingScreen.dart';
import 'package:library_project/feature/onboarding/viewmodel/onboarding_notifier.dart';

class RootScreen extends ConsumerWidget {
  const RootScreen({super.key});
  static const String routeName = '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isOnboardingCompleted = ref.watch(onboardingNotifierProvider);

    if (authState is AuthenticationLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authState is AuthenticationLoaded) {
      final role = authState.user.role;

      if (role == 'Admin' || role == 'Librarian') {
        return const AdminMainScreen();
      }

      // Regular members go to the member dashboard.
      return const MemberMainScreen();
    }

    // Not authenticated yet
    // Check if onboarding has been completed
    if (!isOnboardingCompleted) {
      return const OnboardingScreen();
    }

    // Onboarding completed, go to login
    return const Login();
  }
}
