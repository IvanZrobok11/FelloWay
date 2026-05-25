// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthSessionGet200Response extends AuthSessionGet200Response {
  @override
  final String? userId;

  factory _$AuthSessionGet200Response(
          [void Function(AuthSessionGet200ResponseBuilder)? updates]) =>
      (AuthSessionGet200ResponseBuilder()..update(updates))._build();

  _$AuthSessionGet200Response._({this.userId}) : super._();
  @override
  AuthSessionGet200Response rebuild(
          void Function(AuthSessionGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthSessionGet200ResponseBuilder toBuilder() =>
      AuthSessionGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthSessionGet200Response && userId == other.userId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthSessionGet200Response')
          ..add('userId', userId))
        .toString();
  }
}

class AuthSessionGet200ResponseBuilder
    implements
        Builder<AuthSessionGet200Response, AuthSessionGet200ResponseBuilder> {
  _$AuthSessionGet200Response? _$v;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  AuthSessionGet200ResponseBuilder() {
    AuthSessionGet200Response._defaults(this);
  }

  AuthSessionGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _userId = $v.userId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthSessionGet200Response other) {
    _$v = other as _$AuthSessionGet200Response;
  }

  @override
  void update(void Function(AuthSessionGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthSessionGet200Response build() => _build();

  _$AuthSessionGet200Response _build() {
    final _$result = _$v ??
        _$AuthSessionGet200Response._(
          userId: userId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
