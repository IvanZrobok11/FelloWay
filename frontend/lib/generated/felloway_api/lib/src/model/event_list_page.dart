//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:felloway_api/src/model/event.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'event_list_page.g.dart';

/// EventListPage
///
/// Properties:
/// * [items]
/// * [nextCursor]
@BuiltValue()
abstract class EventListPage
    implements Built<EventListPage, EventListPageBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<Event>? get items;

  @BuiltValueField(wireName: r'nextCursor')
  String? get nextCursor;

  EventListPage._();

  factory EventListPage([void updates(EventListPageBuilder b)]) =
      _$EventListPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EventListPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EventListPage> get serializer =>
      _$EventListPageSerializer();
}

class _$EventListPageSerializer implements PrimitiveSerializer<EventListPage> {
  @override
  final Iterable<Type> types = const [EventListPage, _$EventListPage];

  @override
  final String wireName = r'EventListPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EventListPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.items != null) {
      yield r'items';
      yield serializers.serialize(
        object.items,
        specifiedType: const FullType(BuiltList, [FullType(Event)]),
      );
    }
    if (object.nextCursor != null) {
      yield r'nextCursor';
      yield serializers.serialize(
        object.nextCursor,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    EventListPage object, {
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
    required EventListPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Event)]),
          ) as BuiltList<Event>;
          result.items.replace(valueDes);
          break;
        case r'nextCursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nextCursor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EventListPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EventListPageBuilder();
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
