import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_scope.dart';

/// Opens Stream channel `trip_{tripId}` scoped to [eventId].
Future<void> openTripChannel(
  BuildContext context, {
  required String tripId,
  required String eventId,
}) async {
  final client = AppScope.streamChatOf(context).client;
  if (client == null) return;
  final channelId = 'trip_$tripId';
  final channel = client.channel(
    'messaging',
    id: channelId,
    extraData: {'kind': 'trip', 'event_id': eventId, 'trip_id': tripId},
  );
  await channel.watch();
  if (!context.mounted) return;
  context.push(
    '/chats/channel?type=messaging&id=${Uri.encodeComponent(channelId)}',
  );
}
