//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'attendee.g.dart';

/// Attendee
///
/// Properties:
/// * [id] 
/// * [displayName] 
/// * [homeCity] 
@BuiltValue()
abstract class Attendee implements Built<Attendee, AttendeeBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'displayName')
  String? get displayName;

  @BuiltValueField(wireName: r'homeCity')
  String? get homeCity;

  Attendee._();

  factory Attendee([void updates(AttendeeBuilder b)]) = _$Attendee;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AttendeeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Attendee> get serializer => _$AttendeeSerializer();
}

class _$AttendeeSerializer implements PrimitiveSerializer<Attendee> {
  @override
  final Iterable<Type> types = const [Attendee, _$Attendee];

  @override
  final String wireName = r'Attendee';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Attendee object, {
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
    if (object.homeCity != null) {
      yield r'homeCity';
      yield serializers.serialize(
        object.homeCity,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Attendee object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AttendeeBuilder result,
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
        case r'homeCity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.homeCity = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Attendee deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AttendeeBuilder();
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

