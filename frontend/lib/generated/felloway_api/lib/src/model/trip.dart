//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trip.g.dart';

/// Trip
///
/// Properties:
/// * [id]
/// * [routeLabel]
/// * [departureAt]
/// * [roleType]
/// * [memberCount]
@BuiltValue()
abstract class Trip implements Built<Trip, TripBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'routeLabel')
  String? get routeLabel;

  @BuiltValueField(wireName: r'departureAt')
  DateTime? get departureAt;

  @BuiltValueField(wireName: r'roleType')
  String? get roleType;

  @BuiltValueField(wireName: r'memberCount')
  int? get memberCount;

  Trip._();

  factory Trip([void updates(TripBuilder b)]) = _$Trip;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Trip> get serializer => _$TripSerializer();
}

class _$TripSerializer implements PrimitiveSerializer<Trip> {
  @override
  final Iterable<Type> types = const [Trip, _$Trip];

  @override
  final String wireName = r'Trip';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Trip object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.routeLabel != null) {
      yield r'routeLabel';
      yield serializers.serialize(
        object.routeLabel,
        specifiedType: const FullType(String),
      );
    }
    if (object.departureAt != null) {
      yield r'departureAt';
      yield serializers.serialize(
        object.departureAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.roleType != null) {
      yield r'roleType';
      yield serializers.serialize(
        object.roleType,
        specifiedType: const FullType(String),
      );
    }
    if (object.memberCount != null) {
      yield r'memberCount';
      yield serializers.serialize(
        object.memberCount,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Trip object, {
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
    required TripBuilder result,
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
        case r'memberCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.memberCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Trip deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripBuilder();
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
