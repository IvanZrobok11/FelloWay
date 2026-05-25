//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:felloway_api/src/model/interest_catalog_item.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_profile.g.dart';

/// UserProfile
///
/// Properties:
/// * [id] 
/// * [displayName] 
/// * [bio] 
/// * [homeCity] 
/// * [interestIds] 
/// * [interests] - Resolved catalog entries for interestIds, ordered by sortOrder
/// * [avatarUrl] 
/// * [aggregateRating] 
@BuiltValue()
abstract class UserProfile implements Built<UserProfile, UserProfileBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'displayName')
  String? get displayName;

  @BuiltValueField(wireName: r'bio')
  String? get bio;

  @BuiltValueField(wireName: r'homeCity')
  String? get homeCity;

  @BuiltValueField(wireName: r'interestIds')
  BuiltList<String>? get interestIds;

  /// Resolved catalog entries for interestIds, ordered by sortOrder
  @BuiltValueField(wireName: r'interests')
  BuiltList<InterestCatalogItem>? get interests;

  @BuiltValueField(wireName: r'avatarUrl')
  String? get avatarUrl;

  @BuiltValueField(wireName: r'aggregateRating')
  double? get aggregateRating;

  UserProfile._();

  factory UserProfile([void updates(UserProfileBuilder b)]) = _$UserProfile;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserProfileBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserProfile> get serializer => _$UserProfileSerializer();
}

class _$UserProfileSerializer implements PrimitiveSerializer<UserProfile> {
  @override
  final Iterable<Type> types = const [UserProfile, _$UserProfile];

  @override
  final String wireName = r'UserProfile';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserProfile object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
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
    if (object.homeCity != null) {
      yield r'homeCity';
      yield serializers.serialize(
        object.homeCity,
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
    if (object.interests != null) {
      yield r'interests';
      yield serializers.serialize(
        object.interests,
        specifiedType: const FullType(BuiltList, [FullType(InterestCatalogItem)]),
      );
    }
    if (object.avatarUrl != null) {
      yield r'avatarUrl';
      yield serializers.serialize(
        object.avatarUrl,
        specifiedType: const FullType(String),
      );
    }
    if (object.aggregateRating != null) {
      yield r'aggregateRating';
      yield serializers.serialize(
        object.aggregateRating,
        specifiedType: const FullType(double),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UserProfile object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserProfileBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
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
        case r'homeCity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.homeCity = valueDes;
          break;
        case r'interestIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.interestIds.replace(valueDes);
          break;
        case r'interests':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(InterestCatalogItem)]),
          ) as BuiltList<InterestCatalogItem>;
          result.interests.replace(valueDes);
          break;
        case r'avatarUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.avatarUrl = valueDes;
          break;
        case r'aggregateRating':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.aggregateRating = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserProfile deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserProfileBuilder();
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

