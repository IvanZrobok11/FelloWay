//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:felloway_api/src/model/trip_join_request.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trips_id_join_requests_get200_response.g.dart';

/// TripsIdJoinRequestsGet200Response
///
/// Properties:
/// * [items]
@BuiltValue()
abstract class TripsIdJoinRequestsGet200Response
    implements
        Built<TripsIdJoinRequestsGet200Response,
            TripsIdJoinRequestsGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<TripJoinRequest>? get items;

  TripsIdJoinRequestsGet200Response._();

  factory TripsIdJoinRequestsGet200Response(
          [void updates(TripsIdJoinRequestsGet200ResponseBuilder b)]) =
      _$TripsIdJoinRequestsGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripsIdJoinRequestsGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TripsIdJoinRequestsGet200Response> get serializer =>
      _$TripsIdJoinRequestsGet200ResponseSerializer();
}

class _$TripsIdJoinRequestsGet200ResponseSerializer
    implements PrimitiveSerializer<TripsIdJoinRequestsGet200Response> {
  @override
  final Iterable<Type> types = const [
    TripsIdJoinRequestsGet200Response,
    _$TripsIdJoinRequestsGet200Response
  ];

  @override
  final String wireName = r'TripsIdJoinRequestsGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripsIdJoinRequestsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.items != null) {
      yield r'items';
      yield serializers.serialize(
        object.items,
        specifiedType: const FullType(BuiltList, [FullType(TripJoinRequest)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TripsIdJoinRequestsGet200Response object, {
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
    required TripsIdJoinRequestsGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(TripJoinRequest)]),
          ) as BuiltList<TripJoinRequest>;
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
  TripsIdJoinRequestsGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripsIdJoinRequestsGet200ResponseBuilder();
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
