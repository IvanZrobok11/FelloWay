import 'package:shared_preferences/shared_preferences.dart';

/// Persists onboarding completion for this install (until [clear]).
class OnboardingPreferences {
  OnboardingPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _kComplete = 'onboarding_complete_v1';

  bool get isComplete => _prefs.getBool(_kComplete) ?? false;

  Future<void> setComplete(bool value) => _prefs.setBool(_kComplete, value);

  Future<void> clear() => _prefs.remove(_kComplete);
}
