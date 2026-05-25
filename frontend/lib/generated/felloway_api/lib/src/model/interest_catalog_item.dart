//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'interest_catalog_item.g.dart';

/// InterestCatalogItem
///
/// Properties:
/// * [id] 
/// * [name] 
/// * [sortOrder] 
@BuiltValue()
abstract class InterestCatalogItem implements Built<InterestCatalogItem, InterestCatalogItemBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'sortOrder')
  int get sortOrder;

  InterestCatalogItem._();

  factory InterestCatalogItem([void updates(InterestCatalogItemBuilder b)]) = _$InterestCatalogItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InterestCatalogItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InterestCatalogItem> get serializer => _$InterestCatalogItemSerializer();
}

class _$InterestCatalogItemSerializer implements PrimitiveSerializer<InterestCatalogItem> {
  @override
  final Iterable<Type> types = const [InterestCatalogItem, _$InterestCatalogItem];

  @override
  final String wireName = r'InterestCatalogItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InterestCatalogItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'sortOrder';
    yield serializers.serialize(
      object.sortOrder,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    InterestCatalogItem object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required InterestCatalogItemBuilder result,
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'sortOrder':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sortOrder = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InterestCatalogItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InterestCatalogItemBuilder();
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

