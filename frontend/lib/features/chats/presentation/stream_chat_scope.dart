import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../../app/app_scope.dart';

/// Provides [StreamChat] only where chat UI needs it (not around the whole app).
///
/// Wrapping [MaterialApp] caused blank screens on mobile web after sign-in.
class FellowayStreamChatScope extends StatelessWidget {
  const FellowayStreamChatScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final client = AppScope.streamChatOf(context).client;
    if (client == null) {
      return child;
    }
    return StreamChat(client: client, child: child);
  }
}
