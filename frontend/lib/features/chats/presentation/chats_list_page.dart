import 'package:flutter/material.dart';
import 'package:felloway_client/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat/stream_chat.dart' as sm;
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../../app/app_scope.dart';
import '../../../shared/widgets/error_display.dart';
import '../data/stream_chat_service.dart';

class ChatsListPage extends StatelessWidget {
  const ChatsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = AppScope.authSessionOf(context).isAuthenticated;
    final stream = AppScope.streamChatOf(context);
    final users = AppScope.usersOf(context);

    if (!auth) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.chatsPlaceholderTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.chatsGuestMessage, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.push('/sign-in'),
                  child: Text(l10n.signInTitle),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: stream,
      builder: (context, _) {
        switch (stream.status) {
          case StreamChatConnectStatus.missingApiKey:
            return Scaffold(
              appBar: AppBar(title: Text(l10n.chatsPlaceholderTitle)),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.chatsStreamKeyHint,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          case StreamChatConnectStatus.demoSkipped:
            return Scaffold(
              appBar: AppBar(title: Text(l10n.chatsPlaceholderTitle)),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l10n.chatsDemoHint, textAlign: TextAlign.center),
                ),
              ),
            );
          case StreamChatConnectStatus.connecting:
            return Scaffold(
              appBar: AppBar(title: Text(l10n.chatsPlaceholderTitle)),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l10n.chatsConnecting),
                  ],
                ),
              ),
            );
          case StreamChatConnectStatus.error:
            return Scaffold(
              appBar: AppBar(title: Text(l10n.chatsPlaceholderTitle)),
              body: ErrorDisplay(
                message: l10n.chatsLoadError(stream.errorMessage ?? '—'),
                onRetry: () {
                  stream.syncWithSession(
                    isAuthenticated: true,
                    usersRepository: users,
                  );
                },
              ),
            );
          case StreamChatConnectStatus.disconnected:
          case StreamChatConnectStatus.connected:
            break;
        }

        final client = stream.client;
        if (client == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.chatsPlaceholderTitle)),
            body: Center(child: Text(l10n.emptyStateTitle)),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(l10n.chatsPlaceholderTitle)),
          body: _ConnectedChatsBody(client: client),
        );
      },
    );
  }
}

class _ConnectedChatsBody extends StatefulWidget {
  const _ConnectedChatsBody({required this.client});

  final sm.StreamChatClient client;

  @override
  State<_ConnectedChatsBody> createState() => _ConnectedChatsBodyState();
}

class _ConnectedChatsBodyState extends State<_ConnectedChatsBody> {
  StreamChannelListController? _controller;

  @override
  void initState() {
    super.initState();
    _bind(widget.client);
  }

  @override
  void didUpdateWidget(covariant _ConnectedChatsBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.client != widget.client) {
      _bind(widget.client);
    }
  }

  void _bind(sm.StreamChatClient client) {
    _controller?.dispose();
    final uid = client.state.currentUser?.id;
    if (uid == null || uid.isEmpty) {
      _controller = null;
      return;
    }
    _controller = StreamChannelListController(
      client: client,
      filter: sm.Filter.in_('members', [uid]),
    );
    _controller!.doInitialLoad();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = _controller;
    if (c == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamChannelListView(
      controller: c,
      onChannelTap: (channel) {
        final id = channel.id;
        if (id == null || id.isEmpty) return;
        final t = channel.type;
        context.push(
          '/chats/channel?type=${Uri.encodeComponent(t)}&id=${Uri.encodeComponent(id)}',
        );
      },
      emptyBuilder: (ctx) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l10n.emptyStateTitle, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
