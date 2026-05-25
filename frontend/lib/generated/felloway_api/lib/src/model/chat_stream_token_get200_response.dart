//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'chat_stream_token_get200_response.g.dart';

/// ChatStreamTokenGet200Response
///
/// Properties:
/// * [token] 
@BuiltValue()
abstract class ChatStreamTokenGet200Response implements Built<ChatStreamTokenGet200Response, ChatStreamTokenGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'token')
  String get token;

  ChatStreamTokenGet200Response._();

  factory ChatStreamTokenGet200Response([void updates(ChatStreamTokenGet200ResponseBuilder b)]) = _$ChatStreamTokenGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChatStreamTokenGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChatStreamTokenGet200Response> get serializer => _$ChatStreamTokenGet200ResponseSerializer();
}

class _$ChatStreamTokenGet200ResponseSerializer implements PrimitiveSerializer<ChatStreamTokenGet200Response> {
  @override
  final Iterable<Type> types = const [ChatStreamTokenGet200Response, _$ChatStreamTokenGet200Response];

  @override
  final String wireName = r'ChatStreamTokenGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChatStreamTokenGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'token';
    yield serializers.serialize(
      object.token,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ChatStreamTokenGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChatStreamTokenGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.token = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ChatStreamTokenGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChatStreamTokenGet200ResponseBuilder();
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

