import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_project/service/preferences_service.dart';

/// Provider to check if onboarding has been completed
final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  return PreferencesService.instance.isOnboardingCompleted();
});

/// StateNotifier to manage onboarding state
class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier() : super(false) {
    _loadOnboardingStatus();
  }

  /// Load the onboarding status from SharedPreferences
  Future<void> _loadOnboardingStatus() async {
    state = PreferencesService.instance.isOnboardingCompleted();
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    await PreferencesService.instance.setOnboardingCompleted();
    state = true;
  }

  /// Reset onboarding status (useful for testing)
  Future<void> resetOnboarding() async {
    await PreferencesService.instance.resetOnboarding();
    state = false;
  }
}

/// Provider for the OnboardingNotifier
final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
      return OnboardingNotifier();
    });
