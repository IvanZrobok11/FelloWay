//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:felloway_api/src/model/trip.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'events_id_trips_get200_response.g.dart';

/// EventsIdTripsGet200Response
///
/// Properties:
/// * [items]
@BuiltValue()
abstract class EventsIdTripsGet200Response
    implements
        Built<EventsIdTripsGet200Response, EventsIdTripsGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<Trip>? get items;

  EventsIdTripsGet200Response._();

  factory EventsIdTripsGet200Response(
          [void updates(EventsIdTripsGet200ResponseBuilder b)]) =
      _$EventsIdTripsGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EventsIdTripsGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EventsIdTripsGet200Response> get serializer =>
      _$EventsIdTripsGet200ResponseSerializer();
}

class _$EventsIdTripsGet200ResponseSerializer
    implements PrimitiveSerializer<EventsIdTripsGet200Response> {
  @override
  final Iterable<Type> types = const [
    EventsIdTripsGet200Response,
    _$EventsIdTripsGet200Response
  ];

  @override
  final String wireName = r'EventsIdTripsGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EventsIdTripsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.items != null) {
      yield r'items';
      yield serializers.serialize(
        object.items,
        specifiedType: const FullType(BuiltList, [FullType(Trip)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    EventsIdTripsGet200Response object, {
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
    required EventsIdTripsGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Trip)]),
          ) as BuiltList<Trip>;
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
  EventsIdTripsGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EventsIdTripsGet200ResponseBuilder();
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
