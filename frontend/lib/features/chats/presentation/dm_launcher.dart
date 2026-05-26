import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat/stream_chat.dart' as sm;
import '../../../app/app_scope.dart';

/// Opens the server-provisioned event-wide channel (`event_{eventId}`).
Future<void> openEventChannel(
  BuildContext context, {
  required String eventId,
}) async {
  final client = AppScope.streamChatOf(context).client;
  if (client == null) return;
  final channelId = 'event_$eventId';
  final channel = client.channel(
    'messaging',
    id: channelId,
    extraData: {'kind': 'event', 'event_id': eventId},
  );
  await channel.watch();
  if (!context.mounted) return;
  context.push(
    '/chats/channel?type=messaging&id=${Uri.encodeComponent(channelId)}',
  );
}

/// Opens or creates a 1:1 channel scoped to [eventId] (extra `event_id`).
Future<void> openOrCreateEventDm(
  BuildContext context, {
  required sm.StreamChatClient client,
  required String otherUserId,
  required String eventId,
}) async {
  final me = client.state.currentUser?.id;
  if (me == null || otherUserId.isEmpty) return;
  final a = me.compareTo(otherUserId) <= 0 ? me : otherUserId;
  final b = me.compareTo(otherUserId) <= 0 ? otherUserId : me;
  final channelId = 'dm_${a}_${b}_$eventId';
  final channel = client.channel(
    'messaging',
    id: channelId,
    extraData: {'event_id': eventId, 'kind': 'dm'},
  );
  await channel.watch();
  if (!context.mounted) return;
  context.push(
    '/chats/channel?type=messaging&id=${Uri.encodeComponent(channelId)}',
  );
}
