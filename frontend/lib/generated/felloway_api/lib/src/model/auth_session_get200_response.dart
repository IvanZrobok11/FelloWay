//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_session_get200_response.g.dart';

/// AuthSessionGet200Response
///
/// Properties:
/// * [userId] 
@BuiltValue()
abstract class AuthSessionGet200Response implements Built<AuthSessionGet200Response, AuthSessionGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'userId')
  String? get userId;

  AuthSessionGet200Response._();

  factory AuthSessionGet200Response([void updates(AuthSessionGet200ResponseBuilder b)]) = _$AuthSessionGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthSessionGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthSessionGet200Response> get serializer => _$AuthSessionGet200ResponseSerializer();
}

class _$AuthSessionGet200ResponseSerializer implements PrimitiveSerializer<AuthSessionGet200Response> {
  @override
  final Iterable<Type> types = const [AuthSessionGet200Response, _$AuthSessionGet200Response];

  @override
  final String wireName = r'AuthSessionGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthSessionGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.userId != null) {
      yield r'userId';
      yield serializers.serialize(
        object.userId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthSessionGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthSessionGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'userId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthSessionGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthSessionGet200ResponseBuilder();
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

