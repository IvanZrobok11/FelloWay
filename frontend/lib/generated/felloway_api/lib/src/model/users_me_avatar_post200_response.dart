//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'users_me_avatar_post200_response.g.dart';

/// UsersMeAvatarPost200Response
///
/// Properties:
/// * [avatarUrl] 
@BuiltValue()
abstract class UsersMeAvatarPost200Response implements Built<UsersMeAvatarPost200Response, UsersMeAvatarPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'avatarUrl')
  String? get avatarUrl;

  UsersMeAvatarPost200Response._();

  factory UsersMeAvatarPost200Response([void updates(UsersMeAvatarPost200ResponseBuilder b)]) = _$UsersMeAvatarPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UsersMeAvatarPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UsersMeAvatarPost200Response> get serializer => _$UsersMeAvatarPost200ResponseSerializer();
}

class _$UsersMeAvatarPost200ResponseSerializer implements PrimitiveSerializer<UsersMeAvatarPost200Response> {
  @override
  final Iterable<Type> types = const [UsersMeAvatarPost200Response, _$UsersMeAvatarPost200Response];

  @override
  final String wireName = r'UsersMeAvatarPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UsersMeAvatarPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.avatarUrl != null) {
      yield r'avatarUrl';
      yield serializers.serialize(
        object.avatarUrl,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UsersMeAvatarPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UsersMeAvatarPost200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'avatarUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.avatarUrl = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UsersMeAvatarPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UsersMeAvatarPost200ResponseBuilder();
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

