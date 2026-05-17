// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_oauth_provider_token_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthOauthProviderTokenPostRequest
    extends AuthOauthProviderTokenPostRequest {
  @override
  final String code;
  @override
  final String redirectUri;
  @override
  final String codeVerifier;

  factory _$AuthOauthProviderTokenPostRequest(
          [void Function(AuthOauthProviderTokenPostRequestBuilder)? updates]) =>
      (AuthOauthProviderTokenPostRequestBuilder()..update(updates))._build();

  _$AuthOauthProviderTokenPostRequest._(
      {required this.code,
      required this.redirectUri,
      required this.codeVerifier})
      : super._();
  @override
  AuthOauthProviderTokenPostRequest rebuild(
          void Function(AuthOauthProviderTokenPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthOauthProviderTokenPostRequestBuilder toBuilder() =>
      AuthOauthProviderTokenPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthOauthProviderTokenPostRequest &&
        code == other.code &&
        redirectUri == other.redirectUri &&
        codeVerifier == other.codeVerifier;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, redirectUri.hashCode);
    _$hash = $jc(_$hash, codeVerifier.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthOauthProviderTokenPostRequest')
          ..add('code', code)
          ..add('redirectUri', redirectUri)
          ..add('codeVerifier', codeVerifier))
        .toString();
  }
}

class AuthOauthProviderTokenPostRequestBuilder
    implements
        Builder<AuthOauthProviderTokenPostRequest,
            AuthOauthProviderTokenPostRequestBuilder> {
  _$AuthOauthProviderTokenPostRequest? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _redirectUri;
  String? get redirectUri => _$this._redirectUri;
  set redirectUri(String? redirectUri) => _$this._redirectUri = redirectUri;

  String? _codeVerifier;
  String? get codeVerifier => _$this._codeVerifier;
  set codeVerifier(String? codeVerifier) => _$this._codeVerifier = codeVerifier;

  AuthOauthProviderTokenPostRequestBuilder() {
    AuthOauthProviderTokenPostRequest._defaults(this);
  }

  AuthOauthProviderTokenPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _redirectUri = $v.redirectUri;
      _codeVerifier = $v.codeVerifier;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthOauthProviderTokenPostRequest other) {
    _$v = other as _$AuthOauthProviderTokenPostRequest;
  }

  @override
  void update(
      void Function(AuthOauthProviderTokenPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthOauthProviderTokenPostRequest build() => _build();

  _$AuthOauthProviderTokenPostRequest _build() {
    final _$result = _$v ??
        _$AuthOauthProviderTokenPostRequest._(
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'AuthOauthProviderTokenPostRequest', 'code'),
          redirectUri: BuiltValueNullFieldError.checkNotNull(
              redirectUri, r'AuthOauthProviderTokenPostRequest', 'redirectUri'),
          codeVerifier: BuiltValueNullFieldError.checkNotNull(codeVerifier,
              r'AuthOauthProviderTokenPostRequest', 'codeVerifier'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
