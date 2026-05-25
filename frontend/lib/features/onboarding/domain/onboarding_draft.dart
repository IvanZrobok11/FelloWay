/// Mutable state passed between onboarding screens via route `extra`.
///
/// During **Get started**, fields are filled on device only. After sign-in,
/// a pending copy may be persisted and sent with `PUT /users/me` once.
class OnboardingDraft {
  OnboardingDraft({
    this.displayName = '',
    List<String>? interests,
    this.hobbies = '',
    this.homeCityLabel = '',
  }) : interests = interests ?? [];

  String displayName;

  /// Catalog interest UUIDs from `GET /interests` (not display labels).
  List<String> interests;
  String hobbies;
  String homeCityLabel;

  Map<String, dynamic> toJson() => {
    'displayName': displayName,
    'interests': interests,
    'hobbies': hobbies,
    'homeCityLabel': homeCityLabel,
  };

  factory OnboardingDraft.fromJson(Map<String, dynamic> json) {
    return OnboardingDraft(
      displayName: json['displayName'] as String? ?? '',
      interests:
          (json['interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      hobbies: json['hobbies'] as String? ?? '',
      homeCityLabel: json['homeCityLabel'] as String? ?? '',
    );
  }
}
