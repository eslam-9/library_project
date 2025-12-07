import 'package:shared_preferences/shared_preferences.dart';

/// Service class to manage SharedPreferences operations
/// Uses singleton pattern for consistent access across the app
class PreferencesService {
  static PreferencesService? _instance;
  static SharedPreferences? _preferences;

  // Private constructor
  PreferencesService._();

  /// Get the singleton instance
  static PreferencesService get instance {
    _instance ??= PreferencesService._();
    return _instance!;
  }

  /// Initialize SharedPreferences
  /// Must be called before using any other methods
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Keys for SharedPreferences
  static const String _onboardingCompletedKey = 'onboarding_completed';

  /// Check if onboarding has been completed
  bool isOnboardingCompleted() {
    return _preferences?.getBool(_onboardingCompletedKey) ?? false;
  }

  /// Mark onboarding as completed
  Future<bool> setOnboardingCompleted() async {
    return await _preferences?.setBool(_onboardingCompletedKey, true) ?? false;
  }

  /// Reset onboarding status (useful for testing)
  Future<bool> resetOnboarding() async {
    return await _preferences?.remove(_onboardingCompletedKey) ?? false;
  }
}
