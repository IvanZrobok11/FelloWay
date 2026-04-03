/// Client-side rules: user can enter the main app only after mandatory onboarding.
abstract final class OnboardingCompletion {
  /// True when all mandatory onboarding fields are present (spec FR-002).
  static bool isSatisfied({
    required String displayName,
    required List<String> interests,
    required String hobbies,
    required String homeCityLabel,
  }) {
    final nameOk = displayName.trim().isNotEmpty;
    final interestsOk = interests.isNotEmpty;
    final hobbiesOk = hobbies.trim().isNotEmpty;
    final cityOk = homeCityLabel.trim().isNotEmpty;
    return nameOk && interestsOk && hobbiesOk && cityOk;
  }
}
