// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_me_avatar_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UsersMeAvatarPost200Response extends UsersMeAvatarPost200Response {
  @override
  final String? avatarUrl;

  factory _$UsersMeAvatarPost200Response(
          [void Function(UsersMeAvatarPost200ResponseBuilder)? updates]) =>
      (UsersMeAvatarPost200ResponseBuilder()..update(updates))._build();

  _$UsersMeAvatarPost200Response._({this.avatarUrl}) : super._();
  @override
  UsersMeAvatarPost200Response rebuild(
          void Function(UsersMeAvatarPost200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UsersMeAvatarPost200ResponseBuilder toBuilder() =>
      UsersMeAvatarPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsersMeAvatarPost200Response &&
        avatarUrl == other.avatarUrl;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, avatarUrl.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UsersMeAvatarPost200Response')
          ..add('avatarUrl', avatarUrl))
        .toString();
  }
}

class UsersMeAvatarPost200ResponseBuilder
    implements
        Builder<UsersMeAvatarPost200Response,
            UsersMeAvatarPost200ResponseBuilder> {
  _$UsersMeAvatarPost200Response? _$v;

  String? _avatarUrl;
  String? get avatarUrl => _$this._avatarUrl;
  set avatarUrl(String? avatarUrl) => _$this._avatarUrl = avatarUrl;

  UsersMeAvatarPost200ResponseBuilder() {
    UsersMeAvatarPost200Response._defaults(this);
  }

  UsersMeAvatarPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _avatarUrl = $v.avatarUrl;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UsersMeAvatarPost200Response other) {
    _$v = other as _$UsersMeAvatarPost200Response;
  }

  @override
  void update(void Function(UsersMeAvatarPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UsersMeAvatarPost200Response build() => _build();

  _$UsersMeAvatarPost200Response _build() {
    final _$result = _$v ??
        _$UsersMeAvatarPost200Response._(
          avatarUrl: avatarUrl,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
