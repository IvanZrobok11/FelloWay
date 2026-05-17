class UserProfile {
  UserProfile({
    required this.id,
    required this.displayName,
    this.bio,
    this.avatarUrl,
    this.linkedinUrl,
    this.facebookUrl,
    this.interests = const [],
    this.hobbies = '',
    this.homeCityLabel = '',
    this.ratingAverage,
  });

  final String id;
  final String displayName;
  final String? bio;
  final String? avatarUrl;
  final String? linkedinUrl;
  final String? facebookUrl;
  final List<String> interests;
  final String hobbies;
  final String homeCityLabel;
  final double? ratingAverage;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      displayName:
          json['displayName'] as String? ?? json['name'] as String? ?? '',
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar'] as String?,
      linkedinUrl: json['linkedinUrl'] as String?,
      facebookUrl: json['facebookUrl'] as String?,
      interests:
          (json['interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      hobbies: json['hobbies'] as String? ?? '',
      homeCityLabel:
          json['homeCity'] as String? ??
          json['city'] as String? ??
          json['homeCityLabel'] as String? ??
          '',
      ratingAverage:
          (json['ratingAverage'] as num?)?.toDouble() ??
          (json['rating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toUpdateBody() {
    return {
      'displayName': displayName,
      'bio': bio,
      'interests': interests,
      'hobbies': hobbies,
      'homeCity': homeCityLabel,
      'linkedinUrl': linkedinUrl,
      'facebookUrl': facebookUrl,
    };
  }
}
