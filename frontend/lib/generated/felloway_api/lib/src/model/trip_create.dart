//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trip_create.g.dart';

/// TripCreate
///
/// Properties:
/// * [routeLabel]
/// * [departureAt]
/// * [roleType]
/// * [originCityId]
@BuiltValue()
abstract class TripCreate implements Built<TripCreate, TripCreateBuilder> {
  @BuiltValueField(wireName: r'routeLabel')
  String get routeLabel;

  @BuiltValueField(wireName: r'departureAt')
  DateTime get departureAt;

  @BuiltValueField(wireName: r'roleType')
  String get roleType;

  @BuiltValueField(wireName: r'originCityId')
  String get originCityId;

  TripCreate._();

  factory TripCreate([void updates(TripCreateBuilder b)]) = _$TripCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TripCreate> get serializer => _$TripCreateSerializer();
}

class _$TripCreateSerializer implements PrimitiveSerializer<TripCreate> {
  @override
  final Iterable<Type> types = const [TripCreate, _$TripCreate];

  @override
  final String wireName = r'TripCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'routeLabel';
    yield serializers.serialize(
      object.routeLabel,
      specifiedType: const FullType(String),
    );
    yield r'departureAt';
    yield serializers.serialize(
      object.departureAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'roleType';
    yield serializers.serialize(
      object.roleType,
      specifiedType: const FullType(String),
    );
    yield r'originCityId';
    yield serializers.serialize(
      object.originCityId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TripCreate object, {
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
    required TripCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'routeLabel':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.routeLabel = valueDes;
          break;
        case r'departureAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.departureAt = valueDes;
          break;
        case r'roleType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.roleType = valueDes;
          break;
        case r'originCityId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.originCityId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TripCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripCreateBuilder();
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
