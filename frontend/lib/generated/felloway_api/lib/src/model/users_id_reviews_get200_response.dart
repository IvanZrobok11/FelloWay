//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:felloway_api/src/model/review.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'users_id_reviews_get200_response.g.dart';

/// UsersIdReviewsGet200Response
///
/// Properties:
/// * [items] 
@BuiltValue()
abstract class UsersIdReviewsGet200Response implements Built<UsersIdReviewsGet200Response, UsersIdReviewsGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<Review>? get items;

  UsersIdReviewsGet200Response._();

  factory UsersIdReviewsGet200Response([void updates(UsersIdReviewsGet200ResponseBuilder b)]) = _$UsersIdReviewsGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UsersIdReviewsGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UsersIdReviewsGet200Response> get serializer => _$UsersIdReviewsGet200ResponseSerializer();
}

class _$UsersIdReviewsGet200ResponseSerializer implements PrimitiveSerializer<UsersIdReviewsGet200Response> {
  @override
  final Iterable<Type> types = const [UsersIdReviewsGet200Response, _$UsersIdReviewsGet200Response];

  @override
  final String wireName = r'UsersIdReviewsGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UsersIdReviewsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.items != null) {
      yield r'items';
      yield serializers.serialize(
        object.items,
        specifiedType: const FullType(BuiltList, [FullType(Review)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UsersIdReviewsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UsersIdReviewsGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Review)]),
          ) as BuiltList<Review>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UsersIdReviewsGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UsersIdReviewsGet200ResponseBuilder();
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

