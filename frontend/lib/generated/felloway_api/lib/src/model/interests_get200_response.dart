//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:felloway_api/src/model/interest_catalog_item.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'interests_get200_response.g.dart';

/// InterestsGet200Response
///
/// Properties:
/// * [items] 
@BuiltValue()
abstract class InterestsGet200Response implements Built<InterestsGet200Response, InterestsGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<InterestCatalogItem> get items;

  InterestsGet200Response._();

  factory InterestsGet200Response([void updates(InterestsGet200ResponseBuilder b)]) = _$InterestsGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InterestsGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InterestsGet200Response> get serializer => _$InterestsGet200ResponseSerializer();
}

class _$InterestsGet200ResponseSerializer implements PrimitiveSerializer<InterestsGet200Response> {
  @override
  final Iterable<Type> types = const [InterestsGet200Response, _$InterestsGet200Response];

  @override
  final String wireName = r'InterestsGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InterestsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(InterestCatalogItem)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    InterestsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required InterestsGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(InterestCatalogItem)]),
          ) as BuiltList<InterestCatalogItem>;
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
  InterestsGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InterestsGet200ResponseBuilder();
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

