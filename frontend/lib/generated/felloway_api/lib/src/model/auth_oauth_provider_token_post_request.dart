//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_oauth_provider_token_post_request.g.dart';

/// AuthOauthProviderTokenPostRequest
///
/// Properties:
/// * [code]
/// * [redirectUri]
/// * [codeVerifier] - PKCE verifier from mobile client
@BuiltValue()
abstract class AuthOauthProviderTokenPostRequest
    implements
        Built<AuthOauthProviderTokenPostRequest,
            AuthOauthProviderTokenPostRequestBuilder> {
  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'redirectUri')
  String get redirectUri;

  /// PKCE verifier from mobile client
  @BuiltValueField(wireName: r'codeVerifier')
  String get codeVerifier;

  AuthOauthProviderTokenPostRequest._();

  factory AuthOauthProviderTokenPostRequest(
          [void updates(AuthOauthProviderTokenPostRequestBuilder b)]) =
      _$AuthOauthProviderTokenPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthOauthProviderTokenPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthOauthProviderTokenPostRequest> get serializer =>
      _$AuthOauthProviderTokenPostRequestSerializer();
}

class _$AuthOauthProviderTokenPostRequestSerializer
    implements PrimitiveSerializer<AuthOauthProviderTokenPostRequest> {
  @override
  final Iterable<Type> types = const [
    AuthOauthProviderTokenPostRequest,
    _$AuthOauthProviderTokenPostRequest
  ];

  @override
  final String wireName = r'AuthOauthProviderTokenPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthOauthProviderTokenPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'redirectUri';
    yield serializers.serialize(
      object.redirectUri,
      specifiedType: const FullType(String),
    );
    yield r'codeVerifier';
    yield serializers.serialize(
      object.codeVerifier,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthOauthProviderTokenPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthOauthProviderTokenPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'redirectUri':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.redirectUri = valueDes;
          break;
        case r'codeVerifier':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.codeVerifier = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthOauthProviderTokenPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthOauthProviderTokenPostRequestBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
