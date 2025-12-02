import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_project/feature/admin/view/admin_dashboard_screen.dart';
import 'package:library_project/feature/authentication/viewmodel/auth_notifier.dart';
import 'package:library_project/feature/authentication/viewmodel/auth_state.dart';
import 'package:library_project/feature/member/view/member_dashboard_screen.dart';
import 'package:library_project/feature/onboarding/view/onboardingScreen.dart';

class RootScreen extends ConsumerWidget {
  const RootScreen({super.key});
  static const String routeName = '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    if (authState is AuthenticationLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authState is AuthenticationLoaded) {
      final role = authState.user.role;

      if (role == 'Admin' || role == 'Librarian') {
        return const AdminDashboardScreen();
      }

      // Regular members go to the member dashboard.
      return const MemberDashboardScreen();
    }

    // Not authenticated yet -> onboarding / auth entry
    return const OnboardingScreen();
  }
}
