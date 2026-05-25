// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserProfile extends UserProfile {
  @override
  final String? id;
  @override
  final String? displayName;
  @override
  final String? bio;
  @override
  final String? homeCity;
  @override
  final BuiltList<String>? interestIds;
  @override
  final BuiltList<InterestCatalogItem>? interests;
  @override
  final String? avatarUrl;
  @override
  final double? aggregateRating;

  factory _$UserProfile([void Function(UserProfileBuilder)? updates]) =>
      (UserProfileBuilder()..update(updates))._build();

  _$UserProfile._(
      {this.id,
      this.displayName,
      this.bio,
      this.homeCity,
      this.interestIds,
      this.interests,
      this.avatarUrl,
      this.aggregateRating})
      : super._();
  @override
  UserProfile rebuild(void Function(UserProfileBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserProfileBuilder toBuilder() => UserProfileBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserProfile &&
        id == other.id &&
        displayName == other.displayName &&
        bio == other.bio &&
        homeCity == other.homeCity &&
        interestIds == other.interestIds &&
        interests == other.interests &&
        avatarUrl == other.avatarUrl &&
        aggregateRating == other.aggregateRating;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, bio.hashCode);
    _$hash = $jc(_$hash, homeCity.hashCode);
    _$hash = $jc(_$hash, interestIds.hashCode);
    _$hash = $jc(_$hash, interests.hashCode);
    _$hash = $jc(_$hash, avatarUrl.hashCode);
    _$hash = $jc(_$hash, aggregateRating.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserProfile')
          ..add('id', id)
          ..add('displayName', displayName)
          ..add('bio', bio)
          ..add('homeCity', homeCity)
          ..add('interestIds', interestIds)
          ..add('interests', interests)
          ..add('avatarUrl', avatarUrl)
          ..add('aggregateRating', aggregateRating))
        .toString();
  }
}

class UserProfileBuilder implements Builder<UserProfile, UserProfileBuilder> {
  _$UserProfile? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _bio;
  String? get bio => _$this._bio;
  set bio(String? bio) => _$this._bio = bio;

  String? _homeCity;
  String? get homeCity => _$this._homeCity;
  set homeCity(String? homeCity) => _$this._homeCity = homeCity;

  ListBuilder<String>? _interestIds;
  ListBuilder<String> get interestIds =>
      _$this._interestIds ??= ListBuilder<String>();
  set interestIds(ListBuilder<String>? interestIds) =>
      _$this._interestIds = interestIds;

  ListBuilder<InterestCatalogItem>? _interests;
  ListBuilder<InterestCatalogItem> get interests =>
      _$this._interests ??= ListBuilder<InterestCatalogItem>();
  set interests(ListBuilder<InterestCatalogItem>? interests) =>
      _$this._interests = interests;

  String? _avatarUrl;
  String? get avatarUrl => _$this._avatarUrl;
  set avatarUrl(String? avatarUrl) => _$this._avatarUrl = avatarUrl;

  double? _aggregateRating;
  double? get aggregateRating => _$this._aggregateRating;
  set aggregateRating(double? aggregateRating) =>
      _$this._aggregateRating = aggregateRating;

  UserProfileBuilder() {
    UserProfile._defaults(this);
  }

  UserProfileBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _displayName = $v.displayName;
      _bio = $v.bio;
      _homeCity = $v.homeCity;
      _interestIds = $v.interestIds?.toBuilder();
      _interests = $v.interests?.toBuilder();
      _avatarUrl = $v.avatarUrl;
      _aggregateRating = $v.aggregateRating;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserProfile other) {
    _$v = other as _$UserProfile;
  }

  @override
  void update(void Function(UserProfileBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserProfile build() => _build();

  _$UserProfile _build() {
    _$UserProfile _$result;
    try {
      _$result = _$v ??
          _$UserProfile._(
            id: id,
            displayName: displayName,
            bio: bio,
            homeCity: homeCity,
            interestIds: _interestIds?.build(),
            interests: _interests?.build(),
            avatarUrl: avatarUrl,
            aggregateRating: aggregateRating,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'interestIds';
        _interestIds?.build();
        _$failedField = 'interests';
        _interests?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'UserProfile', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
