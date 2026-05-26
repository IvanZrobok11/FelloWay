import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:stream_chat/stream_chat.dart' as sm;

import '../../../app/config/app_config.dart';
import '../../../shared/errors/app_failure.dart';
import '../../../shared/errors/result.dart';
import '../../../shared/network/api_client.dart';
import '../../profile/data/users_repository.dart';

// Live mode: Stream token path may use mock/dev until fully wired (005 quickstart).
enum StreamChatConnectStatus {
  disconnected,
  connecting,
  connected,
  missingApiKey,
  error,
}

/// Owns [sm.StreamChatClient] lifecycle: fetches token from backend, connects on
/// sign-in, disconnects on sign-out.
class StreamChatService extends ChangeNotifier {
  StreamChatService({required AppConfig config, required ApiClient apiClient})
    : _config = config,
      _api = apiClient;

  final AppConfig _config;
  final ApiClient _api;

  sm.StreamChatClient? _client;
  StreamChatConnectStatus _status = StreamChatConnectStatus.disconnected;
  String? _errorMessage;
  String? _connectedUserId;

  sm.StreamChatClient? get client =>
      _status == StreamChatConnectStatus.connected ? _client : null;

  StreamChatConnectStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isReady => client != null && client!.state.currentUser != null;

  Future<void> syncWithSession({
    required bool isAuthenticated,
    required UsersRepository usersRepository,
  }) async {
    if (!isAuthenticated) {
      await disconnect();
      return;
    }
    if (_config.streamApiKey.isEmpty) {
      _setState(StreamChatConnectStatus.missingApiKey, null);
      return;
    }

    final meResult = await usersRepository.getMe();
    switch (meResult) {
      case Success(:final value):
        final uid = value.id;
        if (uid.isEmpty) {
          _setState(StreamChatConnectStatus.error, 'Profile has no user id');
          return;
        }
        if (_connectedUserId == uid && _client != null) {
          final u = _client!.state.currentUser;
          if (u != null) {
            _setState(StreamChatConnectStatus.connected, null);
            return;
          }
        }
        await _connect(uid, value.displayName);
      case Failure(:final error):
        _setState(StreamChatConnectStatus.error, error.message);
    }
  }

  Future<void> _connect(String userId, String name) async {
    _setState(StreamChatConnectStatus.connecting, null);
    try {
      final tokenResult = await _fetchStreamToken();
      switch (tokenResult) {
        case Success(:final value):
          final token = value;
          if (_client != null) {
            try {
              await _client!.disconnectUser(flushChatPersistence: false);
            } catch (_) {
              _client = null;
            }
          }
          _client ??= sm.StreamChatClient(
            _config.streamApiKey,
            logLevel: Level.OFF,
          );
          await _client!.connectUser(
            sm.User(id: userId, name: name.isEmpty ? null : name),
            token,
          );
          _connectedUserId = userId;
          _setState(StreamChatConnectStatus.connected, null);
        case Failure(:final error):
          _client = null;
          _connectedUserId = null;
          _setState(StreamChatConnectStatus.error, error.message);
      }
    } catch (e) {
      _client = null;
      _connectedUserId = null;
      _setState(StreamChatConnectStatus.error, e.toString());
    }
  }

  Future<Result<String>> _fetchStreamToken() async {
    try {
      final res = await _api.dio.get<Map<String, dynamic>>(
        '/chat/stream-token',
      );
      final data = res.data;
      final token =
          data?['token'] as String? ?? data?['streamToken'] as String?;
      if (token == null || token.isEmpty) {
        return const Failure(
          ValidationFailure('Missing stream token in response'),
        );
      }
      return Success(token);
    } catch (e) {
      return Failure(_api.mapDioError(e));
    }
  }

  Future<void> disconnect() async {
    final c = _client;
    if (c != null) {
      try {
        await c.disconnectUser(flushChatPersistence: false);
      } catch (_) {
        // ignore
      }
    }
    _client = null;
    _connectedUserId = null;
    _setState(StreamChatConnectStatus.disconnected, null);
  }

  /// Best-effort: stop watching event-scoped channels after local leave.
  Future<void> onLeftEvent(String eventId) async {
    final c = client;
    if (c == null) return;
    final uid = c.state.currentUser?.id;
    if (uid == null) return;
    try {
      final ch = c.channel('messaging', id: 'event_$eventId');
      await ch.removeMembers([uid]);
    } catch (_) {
      // Server may already remove membership on DELETE /attend.
    }
  }

  void _setState(StreamChatConnectStatus s, String? message) {
    _status = s;
    _errorMessage = message;
    notifyListeners();
  }
}
