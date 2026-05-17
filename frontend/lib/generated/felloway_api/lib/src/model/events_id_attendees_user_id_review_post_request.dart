//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'events_id_attendees_user_id_review_post_request.g.dart';

/// EventsIdAttendeesUserIdReviewPostRequest
///
/// Properties:
/// * [rating]
/// * [comment]
@BuiltValue()
abstract class EventsIdAttendeesUserIdReviewPostRequest
    implements
        Built<EventsIdAttendeesUserIdReviewPostRequest,
            EventsIdAttendeesUserIdReviewPostRequestBuilder> {
  @BuiltValueField(wireName: r'rating')
  int get rating;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  EventsIdAttendeesUserIdReviewPostRequest._();

  factory EventsIdAttendeesUserIdReviewPostRequest(
          [void updates(EventsIdAttendeesUserIdReviewPostRequestBuilder b)]) =
      _$EventsIdAttendeesUserIdReviewPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EventsIdAttendeesUserIdReviewPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EventsIdAttendeesUserIdReviewPostRequest> get serializer =>
      _$EventsIdAttendeesUserIdReviewPostRequestSerializer();
}

class _$EventsIdAttendeesUserIdReviewPostRequestSerializer
    implements PrimitiveSerializer<EventsIdAttendeesUserIdReviewPostRequest> {
  @override
  final Iterable<Type> types = const [
    EventsIdAttendeesUserIdReviewPostRequest,
    _$EventsIdAttendeesUserIdReviewPostRequest
  ];

  @override
  final String wireName = r'EventsIdAttendeesUserIdReviewPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EventsIdAttendeesUserIdReviewPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'rating';
    yield serializers.serialize(
      object.rating,
      specifiedType: const FullType(int),
    );
    if (object.comment != null) {
      yield r'comment';
      yield serializers.serialize(
        object.comment,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    EventsIdAttendeesUserIdReviewPostRequest object, {
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
    required EventsIdAttendeesUserIdReviewPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'rating':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.rating = valueDes;
          break;
        case r'comment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.comment = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EventsIdAttendeesUserIdReviewPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EventsIdAttendeesUserIdReviewPostRequestBuilder();
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
