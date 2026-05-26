import 'package:flutter/foundation.dart';

import '../../features/onboarding/data/onboarding_preferences.dart';
import '../initial_location_from_browser.dart';

/// First route for [GoRouter]. On web, prefer the browser path so OAuth
/// `/auth/success?ticket=...` is not overridden by onboarding defaults.
String resolveInitialLocation({
  required bool isWeb,
  required OnboardingPreferences onboardingPreferences,
}) {
  if (isWeb) {
    final fromBrowser = initialLocationFromBrowser();
    if (fromBrowser != null && fromBrowser.isNotEmpty) {
      return fromBrowser;
    }
  }
  return onboardingPreferences.isComplete
      ? '/events'
      : '/onboarding/welcome';
}
