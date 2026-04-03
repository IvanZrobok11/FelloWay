import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

/// Maps FCM / APNs payload data to in-app routes and applies navigation.
///
/// Wire [firebase_messaging] (or another push SDK) to call [handleForegroundData]
/// and [handleNotificationOpened] with the remote message `data` map.
/// [registerMessagingBridge] is a no-op placeholder until that integration lands.
class PushHandler {
  PushHandler._();

  static final _log = Logger('PushHandler');

  /// Root key for [MaterialApp.router] / [GoRouter] — use for SnackBars from
  /// foreground handlers when no [BuildContext] is available.
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter? _router;

  static void attach(GoRouter router) {
    _router = router;
  }

  static void detach() {
    _router = null;
  }

  /// Parses backend / platform payload into a GoRouter location.
  ///
  /// Supported keys (all optional; first match wins):
  /// - `deepLink` / `link`: full path, e.g. `/event/abc` or `/chats/channel?type=messaging&id=x`
  /// - `eventId`: opens `/event/{eventId}`
  /// - `channelType` + `channelId`: opens Stream channel screen
  /// - `screen` = `chats` with optional `channelType` / `channelId`
  static String? routeForData(Map<String, dynamic> data) {
    String? s(dynamic v) => v?.toString();

    final deep = s(data['deepLink'] ?? data['link'] ?? data['url']);
    if (deep != null && deep.isNotEmpty) {
      final uri = Uri.tryParse(deep);
      if (uri != null) {
        if (uri.hasScheme) {
          return uri.path.isNotEmpty
              ? '${uri.path}${uri.hasQuery ? '?${uri.query}' : ''}'
              : null;
        }
        return deep.startsWith('/') ? deep : '/$deep';
      }
    }

    final eventId = s(data['eventId']);
    if (eventId != null && eventId.isNotEmpty) {
      return '/event/$eventId';
    }

    final channelType = s(data['channelType'] ?? data['type']) ?? 'messaging';
    final channelId = s(data['channelId'] ?? data['cid']);
    if (channelId != null && channelId.isNotEmpty) {
      final enc = Uri.encodeComponent(channelId);
      final t = Uri.encodeComponent(channelType);
      return '/chats/channel?type=$t&id=$enc';
    }

    if (s(data['screen']) == 'chats') {
      return '/chats';
    }

    return null;
  }

  static void _go(String location) {
    final r = _router;
    if (r == null) {
      _log.warning('No GoRouter attached; cannot navigate to $location');
      return;
    }
    r.go(location);
  }

  /// Call when user taps a notification (terminated / background).
  static void handleNotificationOpened(Map<String, dynamic> data) {
    final loc = routeForData(data);
    if (loc != null) {
      _go(loc);
    } else {
      _log.fine('No route for push data: $data');
    }
  }

  /// Call for foreground messages — navigates optionally and shows a banner.
  static void handleForegroundData(
    Map<String, dynamic> data, {
    bool navigate = false,
  }) {
    final loc = routeForData(data);
    if (navigate && loc != null) {
      _go(loc);
      return;
    }
    final ctx = rootNavigatorKey.currentContext;
    if (ctx != null && loc != null) {
      ScaffoldMessenger.maybeOf(ctx)?.showSnackBar(
        SnackBar(
          content: const Text('New message'),
          action: SnackBarAction(label: 'Open', onPressed: () => _go(loc)),
        ),
      );
    }
  }

  /// Placeholder for FCM/APNs registration and listener setup.
  static Future<void> registerMessagingBridge() async {}
}
