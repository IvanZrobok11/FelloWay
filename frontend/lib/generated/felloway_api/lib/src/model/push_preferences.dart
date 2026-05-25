//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'push_preferences.g.dart';

/// PushPreferences
///
/// Properties:
/// * [globalEnabled] 
/// * [eventMessages] 
/// * [tripMessages] 
/// * [directMessages] 
@BuiltValue()
abstract class PushPreferences implements Built<PushPreferences, PushPreferencesBuilder> {
  @BuiltValueField(wireName: r'globalEnabled')
  bool? get globalEnabled;

  @BuiltValueField(wireName: r'eventMessages')
  bool? get eventMessages;

  @BuiltValueField(wireName: r'tripMessages')
  bool? get tripMessages;

  @BuiltValueField(wireName: r'directMessages')
  bool? get directMessages;

  PushPreferences._();

  factory PushPreferences([void updates(PushPreferencesBuilder b)]) = _$PushPreferences;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PushPreferencesBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PushPreferences> get serializer => _$PushPreferencesSerializer();
}

class _$PushPreferencesSerializer implements PrimitiveSerializer<PushPreferences> {
  @override
  final Iterable<Type> types = const [PushPreferences, _$PushPreferences];

  @override
  final String wireName = r'PushPreferences';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PushPreferences object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.globalEnabled != null) {
      yield r'globalEnabled';
      yield serializers.serialize(
        object.globalEnabled,
        specifiedType: const FullType(bool),
      );
    }
    if (object.eventMessages != null) {
      yield r'eventMessages';
      yield serializers.serialize(
        object.eventMessages,
        specifiedType: const FullType(bool),
      );
    }
    if (object.tripMessages != null) {
      yield r'tripMessages';
      yield serializers.serialize(
        object.tripMessages,
        specifiedType: const FullType(bool),
      );
    }
    if (object.directMessages != null) {
      yield r'directMessages';
      yield serializers.serialize(
        object.directMessages,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PushPreferences object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PushPreferencesBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'globalEnabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.globalEnabled = valueDes;
          break;
        case r'eventMessages':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.eventMessages = valueDes;
          break;
        case r'tripMessages':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.tripMessages = valueDes;
          break;
        case r'directMessages':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.directMessages = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PushPreferences deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PushPreferencesBuilder();
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

