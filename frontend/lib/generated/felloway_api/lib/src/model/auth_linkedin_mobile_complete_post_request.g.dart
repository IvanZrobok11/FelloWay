// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_linkedin_mobile_complete_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthLinkedinMobileCompletePostRequest
    extends AuthLinkedinMobileCompletePostRequest {
  @override
  final String ticket;

  factory _$AuthLinkedinMobileCompletePostRequest(
          [void Function(AuthLinkedinMobileCompletePostRequestBuilder)?
              updates]) =>
      (AuthLinkedinMobileCompletePostRequestBuilder()..update(updates))
          ._build();

  _$AuthLinkedinMobileCompletePostRequest._({required this.ticket}) : super._();
  @override
  AuthLinkedinMobileCompletePostRequest rebuild(
          void Function(AuthLinkedinMobileCompletePostRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthLinkedinMobileCompletePostRequestBuilder toBuilder() =>
      AuthLinkedinMobileCompletePostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthLinkedinMobileCompletePostRequest &&
        ticket == other.ticket;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ticket.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'AuthLinkedinMobileCompletePostRequest')
          ..add('ticket', ticket))
        .toString();
  }
}

class AuthLinkedinMobileCompletePostRequestBuilder
    implements
        Builder<AuthLinkedinMobileCompletePostRequest,
            AuthLinkedinMobileCompletePostRequestBuilder> {
  _$AuthLinkedinMobileCompletePostRequest? _$v;

  String? _ticket;
  String? get ticket => _$this._ticket;
  set ticket(String? ticket) => _$this._ticket = ticket;

  AuthLinkedinMobileCompletePostRequestBuilder() {
    AuthLinkedinMobileCompletePostRequest._defaults(this);
  }

  AuthLinkedinMobileCompletePostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ticket = $v.ticket;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthLinkedinMobileCompletePostRequest other) {
    _$v = other as _$AuthLinkedinMobileCompletePostRequest;
  }

  @override
  void update(
      void Function(AuthLinkedinMobileCompletePostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthLinkedinMobileCompletePostRequest build() => _build();

  _$AuthLinkedinMobileCompletePostRequest _build() {
    final _$result = _$v ??
        _$AuthLinkedinMobileCompletePostRequest._(
          ticket: BuiltValueNullFieldError.checkNotNull(
              ticket, r'AuthLinkedinMobileCompletePostRequest', 'ticket'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
