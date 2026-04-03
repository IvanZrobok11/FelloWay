/// Mutable state passed between onboarding screens via route `extra`.
class OnboardingDraft {
  OnboardingDraft({
    this.displayName = '',
    List<String>? interests,
    this.hobbies = '',
    this.homeCityLabel = '',
  }) : interests = interests ?? [];

  String displayName;
  List<String> interests;
  String hobbies;
  String homeCityLabel;
}
