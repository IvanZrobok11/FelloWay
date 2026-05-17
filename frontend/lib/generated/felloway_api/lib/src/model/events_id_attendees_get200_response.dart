//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:felloway_api/src/model/attendee.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'events_id_attendees_get200_response.g.dart';

/// EventsIdAttendeesGet200Response
///
/// Properties:
/// * [items]
@BuiltValue()
abstract class EventsIdAttendeesGet200Response
    implements
        Built<EventsIdAttendeesGet200Response,
            EventsIdAttendeesGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<Attendee>? get items;

  EventsIdAttendeesGet200Response._();

  factory EventsIdAttendeesGet200Response(
          [void updates(EventsIdAttendeesGet200ResponseBuilder b)]) =
      _$EventsIdAttendeesGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EventsIdAttendeesGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EventsIdAttendeesGet200Response> get serializer =>
      _$EventsIdAttendeesGet200ResponseSerializer();
}

class _$EventsIdAttendeesGet200ResponseSerializer
    implements PrimitiveSerializer<EventsIdAttendeesGet200Response> {
  @override
  final Iterable<Type> types = const [
    EventsIdAttendeesGet200Response,
    _$EventsIdAttendeesGet200Response
  ];

  @override
  final String wireName = r'EventsIdAttendeesGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EventsIdAttendeesGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.items != null) {
      yield r'items';
      yield serializers.serialize(
        object.items,
        specifiedType: const FullType(BuiltList, [FullType(Attendee)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    EventsIdAttendeesGet200Response object, {
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
    required EventsIdAttendeesGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Attendee)]),
          ) as BuiltList<Attendee>;
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
  EventsIdAttendeesGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EventsIdAttendeesGet200ResponseBuilder();
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
