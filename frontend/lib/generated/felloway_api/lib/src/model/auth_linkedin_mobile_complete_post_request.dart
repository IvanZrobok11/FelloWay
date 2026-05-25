//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_linkedin_mobile_complete_post_request.g.dart';

/// AuthLinkedinMobileCompletePostRequest
///
/// Properties:
/// * [ticket] 
@BuiltValue()
abstract class AuthLinkedinMobileCompletePostRequest implements Built<AuthLinkedinMobileCompletePostRequest, AuthLinkedinMobileCompletePostRequestBuilder> {
  @BuiltValueField(wireName: r'ticket')
  String get ticket;

  AuthLinkedinMobileCompletePostRequest._();

  factory AuthLinkedinMobileCompletePostRequest([void updates(AuthLinkedinMobileCompletePostRequestBuilder b)]) = _$AuthLinkedinMobileCompletePostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthLinkedinMobileCompletePostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthLinkedinMobileCompletePostRequest> get serializer => _$AuthLinkedinMobileCompletePostRequestSerializer();
}

class _$AuthLinkedinMobileCompletePostRequestSerializer implements PrimitiveSerializer<AuthLinkedinMobileCompletePostRequest> {
  @override
  final Iterable<Type> types = const [AuthLinkedinMobileCompletePostRequest, _$AuthLinkedinMobileCompletePostRequest];

  @override
  final String wireName = r'AuthLinkedinMobileCompletePostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthLinkedinMobileCompletePostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ticket';
    yield serializers.serialize(
      object.ticket,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthLinkedinMobileCompletePostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthLinkedinMobileCompletePostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ticket':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ticket = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthLinkedinMobileCompletePostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthLinkedinMobileCompletePostRequestBuilder();
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

