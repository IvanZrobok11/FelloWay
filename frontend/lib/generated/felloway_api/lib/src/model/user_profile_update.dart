//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_profile_update.g.dart';

/// UserProfileUpdate
///
/// Properties:
/// * [displayName] 
/// * [bio] 
/// * [homeCityId] 
/// * [interestIds] 
@BuiltValue()
abstract class UserProfileUpdate implements Built<UserProfileUpdate, UserProfileUpdateBuilder> {
  @BuiltValueField(wireName: r'displayName')
  String? get displayName;

  @BuiltValueField(wireName: r'bio')
  String? get bio;

  @BuiltValueField(wireName: r'homeCityId')
  String? get homeCityId;

  @BuiltValueField(wireName: r'interestIds')
  BuiltList<String>? get interestIds;

  UserProfileUpdate._();

  factory UserProfileUpdate([void updates(UserProfileUpdateBuilder b)]) = _$UserProfileUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserProfileUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserProfileUpdate> get serializer => _$UserProfileUpdateSerializer();
}

class _$UserProfileUpdateSerializer implements PrimitiveSerializer<UserProfileUpdate> {
  @override
  final Iterable<Type> types = const [UserProfileUpdate, _$UserProfileUpdate];

  @override
  final String wireName = r'UserProfileUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserProfileUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.displayName != null) {
      yield r'displayName';
      yield serializers.serialize(
        object.displayName,
        specifiedType: const FullType(String),
      );
    }
    if (object.bio != null) {
      yield r'bio';
      yield serializers.serialize(
        object.bio,
        specifiedType: const FullType(String),
      );
    }
    if (object.homeCityId != null) {
      yield r'homeCityId';
      yield serializers.serialize(
        object.homeCityId,
        specifiedType: const FullType(String),
      );
    }
    if (object.interestIds != null) {
      yield r'interestIds';
      yield serializers.serialize(
        object.interestIds,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UserProfileUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserProfileUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'displayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        case r'bio':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.bio = valueDes;
          break;
        case r'homeCityId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.homeCityId = valueDes;
          break;
        case r'interestIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.interestIds.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserProfileUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserProfileUpdateBuilder();
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

