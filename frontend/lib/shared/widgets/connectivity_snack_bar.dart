import 'package:flutter/material.dart';
import 'package:felloway_client/l10n/app_localizations.dart';

import '../../app/notifications/push_handler.dart';

/// Floating snack bar for offline / unreachable backend on user actions.
abstract final class ConnectivitySnackBar {
  static const _backgroundColor = Color(0xFF212121);
  static const _duration = Duration(seconds: 4);
  static DateTime? _lastGlobalShown;

  /// Shows via [PushHandler.rootNavigatorKey] when no local [BuildContext] exists.
  static void showGlobal({
    Duration throttle = const Duration(seconds: 30),
  }) {
    final context = PushHandler.rootNavigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    final now = DateTime.now();
    if (_lastGlobalShown != null &&
        now.difference(_lastGlobalShown!) < throttle) {
      return;
    }
    _lastGlobalShown = now;
    show(context);
  }

  /// Clears existing snack bars, then shows the connectivity notification.
  static void show(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _backgroundColor,
        duration: _duration,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Semantics(
          liveRegion: true,
          child: Row(
            children: [
              const Icon(Icons.wifi_off, color: Colors.white70),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.connectivityActionUnavailable,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              InkWell(
                onTap: () => messenger.hideCurrentSnackBar(),
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
