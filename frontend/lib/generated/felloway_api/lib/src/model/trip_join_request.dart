//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trip_join_request.g.dart';

/// TripJoinRequest
///
/// Properties:
/// * [id]
/// * [requesterId]
/// * [status]
@BuiltValue()
abstract class TripJoinRequest
    implements Built<TripJoinRequest, TripJoinRequestBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'requesterId')
  String? get requesterId;

  @BuiltValueField(wireName: r'status')
  TripJoinRequestStatusEnum? get status;
  // enum statusEnum {  pending,  approved,  rejected,  cancelled,  };

  TripJoinRequest._();

  factory TripJoinRequest([void updates(TripJoinRequestBuilder b)]) =
      _$TripJoinRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripJoinRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TripJoinRequest> get serializer =>
      _$TripJoinRequestSerializer();
}

class _$TripJoinRequestSerializer
    implements PrimitiveSerializer<TripJoinRequest> {
  @override
  final Iterable<Type> types = const [TripJoinRequest, _$TripJoinRequest];

  @override
  final String wireName = r'TripJoinRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripJoinRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.requesterId != null) {
      yield r'requesterId';
      yield serializers.serialize(
        object.requesterId,
        specifiedType: const FullType(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(TripJoinRequestStatusEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TripJoinRequest object, {
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
    required TripJoinRequestBuilder result,
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
        case r'requesterId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.requesterId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TripJoinRequestStatusEnum),
          ) as TripJoinRequestStatusEnum;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TripJoinRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripJoinRequestBuilder();
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

class TripJoinRequestStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'pending')
  static const TripJoinRequestStatusEnum pending =
      _$tripJoinRequestStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'approved')
  static const TripJoinRequestStatusEnum approved =
      _$tripJoinRequestStatusEnum_approved;
  @BuiltValueEnumConst(wireName: r'rejected')
  static const TripJoinRequestStatusEnum rejected =
      _$tripJoinRequestStatusEnum_rejected;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const TripJoinRequestStatusEnum cancelled =
      _$tripJoinRequestStatusEnum_cancelled;

  static Serializer<TripJoinRequestStatusEnum> get serializer =>
      _$tripJoinRequestStatusEnumSerializer;

  const TripJoinRequestStatusEnum._(String name) : super(name);

  static BuiltSet<TripJoinRequestStatusEnum> get values =>
      _$tripJoinRequestStatusEnumValues;
  static TripJoinRequestStatusEnum valueOf(String name) =>
      _$tripJoinRequestStatusEnumValueOf(name);
}
