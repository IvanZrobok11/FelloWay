import '../../onboarding/domain/interest_catalog_item.dart';

class UserProfile {
  UserProfile({
    required this.id,
    required this.displayName,
    this.bio,
    this.avatarUrl,
    this.linkedinUrl,
    this.facebookUrl,
    this.interests = const [],
    this.interestItems = const [],
    this.hobbies = '',
    this.homeCityLabel = '',
    this.homeCityId,
    this.ratingAverage,
  });

  final String id;
  final String displayName;
  final String? bio;
  final String? avatarUrl;
  final String? linkedinUrl;
  final String? facebookUrl;

  /// Catalog interest UUIDs for `PUT /users/me` (`interestIds`).
  final List<String> interests;

  /// Resolved catalog rows from `GET /users/me` when available.
  final List<InterestCatalogItem> interestItems;
  final String hobbies;
  final String homeCityLabel;
  final String? homeCityId;
  final double? ratingAverage;

  List<String> get interestLabels => interestItems.isNotEmpty
      ? interestItems.map((e) => e.name).toList()
      : interests;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final interestIds = (json['interestIds'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList();
    final enriched = (json['interests'] as List<dynamic>?)
        ?.whereType<Map<String, dynamic>>()
        .map(InterestCatalogItem.fromJson)
        .toList();
    final legacyInterests = (json['interests'] as List<dynamic>?)
        ?.where((e) => e is! Map<String, dynamic>)
        .map((e) => e.toString())
        .toList();

    final ids = interestIds ??
        (enriched?.isNotEmpty == true
            ? enriched!.map((e) => e.id).toList()
            : legacyInterests) ??
        const <String>[];

    return UserProfile(
      id: json['id']?.toString() ?? '',
      displayName:
          json['displayName'] as String? ?? json['name'] as String? ?? '',
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar'] as String?,
      linkedinUrl: json['linkedinUrl'] as String?,
      facebookUrl: json['facebookUrl'] as String?,
      interests: ids,
      interestItems: enriched ?? const [],
      hobbies: json['hobbies'] as String? ?? '',
      homeCityLabel:
          json['homeCity'] as String? ??
          json['city'] as String? ??
          json['homeCityLabel'] as String? ??
          '',
      homeCityId: json['homeCityId']?.toString(),
      ratingAverage:
          (json['aggregateRating'] as num?)?.toDouble() ??
          (json['ratingAverage'] as num?)?.toDouble() ??
          (json['rating'] as num?)?.toDouble(),
    );
  }

  /// Contract `UserProfileUpdate` body for `PUT /users/me`.
  Map<String, dynamic> toUpdateBody() {
    final body = <String, dynamic>{
      if (displayName.trim().isNotEmpty) 'displayName': displayName.trim(),
      if (bio != null) 'bio': bio,
    };
    final cityId = homeCityId?.trim();
    if (cityId != null && cityId.isNotEmpty && _looksLikeUuid(cityId)) {
      body['homeCityId'] = cityId;
    }
    final ids = interests.where(_looksLikeUuid).toList();
    if (ids.isNotEmpty) {
      body['interestIds'] = ids;
    } else if (interests.isEmpty) {
      body['interestIds'] = <String>[];
    }
    return body;
  }

  static bool _looksLikeUuid(String value) {
    final v = value.trim();
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(v);
  }
}
