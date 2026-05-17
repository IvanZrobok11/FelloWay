// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_stream_token_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChatStreamTokenGet200Response extends ChatStreamTokenGet200Response {
  @override
  final String token;

  factory _$ChatStreamTokenGet200Response(
          [void Function(ChatStreamTokenGet200ResponseBuilder)? updates]) =>
      (ChatStreamTokenGet200ResponseBuilder()..update(updates))._build();

  _$ChatStreamTokenGet200Response._({required this.token}) : super._();
  @override
  ChatStreamTokenGet200Response rebuild(
          void Function(ChatStreamTokenGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChatStreamTokenGet200ResponseBuilder toBuilder() =>
      ChatStreamTokenGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChatStreamTokenGet200Response && token == other.token;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChatStreamTokenGet200Response')
          ..add('token', token))
        .toString();
  }
}

class ChatStreamTokenGet200ResponseBuilder
    implements
        Builder<ChatStreamTokenGet200Response,
            ChatStreamTokenGet200ResponseBuilder> {
  _$ChatStreamTokenGet200Response? _$v;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  ChatStreamTokenGet200ResponseBuilder() {
    ChatStreamTokenGet200Response._defaults(this);
  }

  ChatStreamTokenGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _token = $v.token;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChatStreamTokenGet200Response other) {
    _$v = other as _$ChatStreamTokenGet200Response;
  }

  @override
  void update(void Function(ChatStreamTokenGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChatStreamTokenGet200Response build() => _build();

  _$ChatStreamTokenGet200Response _build() {
    final _$result = _$v ??
        _$ChatStreamTokenGet200Response._(
          token: BuiltValueNullFieldError.checkNotNull(
              token, r'ChatStreamTokenGet200Response', 'token'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
