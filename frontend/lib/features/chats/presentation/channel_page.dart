import 'package:flutter/material.dart';
import 'package:felloway_client/l10n/app_localizations.dart';
import 'package:stream_chat/stream_chat.dart' as sm;
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../../app/app_scope.dart';
import '../application/chat_access_controller.dart';
import '../domain/chat_access_policy.dart';
import 'report_sheet.dart';
import '../../profile/presentation/block_user_action.dart';

String? eventIdFromChannel(sm.Channel channel) {
  final extra = channel.extraData;
  final dynamic eid = extra['event_id'];
  if (eid is String && eid.isNotEmpty) return eid;
  final id = channel.id;
  if (id != null && id.startsWith('event_')) {
    return id.substring(6);
  }
  return null;
}

bool channelComposerEnabled(sm.Channel channel, ChatAccessController access) {
  final eid = eventIdFromChannel(channel);
  if (eid == null) return true;
  return ChatAccessPolicy.isEventScopedDmComposerEnabled(
    currentUserAttendsEvent: access.isAttending(eid),
  );
}

class ChannelPage extends StatefulWidget {
  const ChannelPage({
    super.key,
    required this.channelType,
    required this.channelId,
  });

  final String channelType;
  final String channelId;

  @override
  State<ChannelPage> createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  Object? _error;
  String? _loadedKey;
  sm.Channel? _channel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final key = '${widget.channelType}:${widget.channelId}';
    if (_loadedKey == key && _channel != null) return;
    _loadedKey = key;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _channel = null;
    });
    try {
      final client = StreamChat.of(context).client;
      final ch = client.channel(widget.channelType, id: widget.channelId);
      await ch.watch();
      if (!mounted) return;
      setState(() => _channel = ch);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final access = AppScope.chatAccessOf(context);

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.chatChannelTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_error.toString(), textAlign: TextAlign.center),
          ),
        ),
      );
    }

    final ch = _channel;
    if (ch == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.chatChannelTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final otherDmUser = _otherMember(ch, StreamChat.of(context).client);

    return ListenableBuilder(
      listenable: access,
      builder: (context, _) {
        final composerOn = channelComposerEnabled(ch, access);
        return StreamChannel(
          channel: ch,
          child: Scaffold(
            appBar: AppBar(
              title: Text(ch.name ?? l10n.chatChannelTitle),
              actions: [
                IconButton(
                  icon: const Icon(Icons.flag_outlined),
                  tooltip: l10n.chatReportTitle,
                  onPressed: () => showReportSheet(context),
                ),
                if (otherDmUser != null)
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'block') {
                        confirmAndBlockUser(
                          context,
                          userId: otherDmUser.$1,
                          displayName: otherDmUser.$2,
                        );
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'block',
                        child: Text(l10n.chatBlockUserConfirm),
                      ),
                    ],
                  ),
              ],
            ),
            body: Column(
              children: [
                Expanded(child: StreamMessageListView()),
                if (composerOn)
                  const StreamMessageInput()
                else
                  Material(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        l10n.chatDmReadOnlyHint,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// (userId, displayName) for the other member in a 1:1-style channel.
(String, String)? _otherMember(sm.Channel channel, sm.StreamChatClient client) {
  final me = client.state.currentUser?.id;
  if (me == null) return null;
  final members = channel.state?.members ?? [];
  if (members.length != 2) return null;
  for (final m in members) {
    final uid = m.user?.id ?? m.userId;
    if (uid != null && uid != me) {
      return (uid, m.user?.name ?? uid);
    }
  }
  return null;
}
