// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserProfileUpdate extends UserProfileUpdate {
  @override
  final String? displayName;
  @override
  final String? bio;
  @override
  final String? homeCityId;
  @override
  final BuiltList<String>? interestIds;

  factory _$UserProfileUpdate(
          [void Function(UserProfileUpdateBuilder)? updates]) =>
      (UserProfileUpdateBuilder()..update(updates))._build();

  _$UserProfileUpdate._(
      {this.displayName, this.bio, this.homeCityId, this.interestIds})
      : super._();
  @override
  UserProfileUpdate rebuild(void Function(UserProfileUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserProfileUpdateBuilder toBuilder() =>
      UserProfileUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserProfileUpdate &&
        displayName == other.displayName &&
        bio == other.bio &&
        homeCityId == other.homeCityId &&
        interestIds == other.interestIds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, bio.hashCode);
    _$hash = $jc(_$hash, homeCityId.hashCode);
    _$hash = $jc(_$hash, interestIds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserProfileUpdate')
          ..add('displayName', displayName)
          ..add('bio', bio)
          ..add('homeCityId', homeCityId)
          ..add('interestIds', interestIds))
        .toString();
  }
}

class UserProfileUpdateBuilder
    implements Builder<UserProfileUpdate, UserProfileUpdateBuilder> {
  _$UserProfileUpdate? _$v;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _bio;
  String? get bio => _$this._bio;
  set bio(String? bio) => _$this._bio = bio;

  String? _homeCityId;
  String? get homeCityId => _$this._homeCityId;
  set homeCityId(String? homeCityId) => _$this._homeCityId = homeCityId;

  ListBuilder<String>? _interestIds;
  ListBuilder<String> get interestIds =>
      _$this._interestIds ??= ListBuilder<String>();
  set interestIds(ListBuilder<String>? interestIds) =>
      _$this._interestIds = interestIds;

  UserProfileUpdateBuilder() {
    UserProfileUpdate._defaults(this);
  }

  UserProfileUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _displayName = $v.displayName;
      _bio = $v.bio;
      _homeCityId = $v.homeCityId;
      _interestIds = $v.interestIds?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserProfileUpdate other) {
    _$v = other as _$UserProfileUpdate;
  }

  @override
  void update(void Function(UserProfileUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserProfileUpdate build() => _build();

  _$UserProfileUpdate _build() {
    _$UserProfileUpdate _$result;
    try {
      _$result = _$v ??
          _$UserProfileUpdate._(
            displayName: displayName,
            bio: bio,
            homeCityId: homeCityId,
            interestIds: _interestIds?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'interestIds';
        _interestIds?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'UserProfileUpdate', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
