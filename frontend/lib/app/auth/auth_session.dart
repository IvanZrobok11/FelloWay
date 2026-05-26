import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../features/auth/data/auth_api.dart';
import '../../features/auth/data/token_storage.dart';
import '../../shared/errors/connectivity_failure.dart';

/// Tracks whether the user has stored credentials (hydrate in [restore]).
class AuthSession extends ChangeNotifier {
  AuthSession({required TokenStorage tokenStorage})
    : _tokenStorage = tokenStorage;

  final TokenStorage _tokenStorage;

  bool _hydrated = false;
  bool _hasSession = false;
  bool _webSessionSyncAttempted = false;
  bool _pendingConnectivityNotice = false;

  bool get isHydrated => _hydrated;
  bool get isAuthenticated => _hasSession;

  /// One-shot flag: API was unreachable on last web session probe (for global snack bar).
  bool consumeConnectivityNotice() {
    if (!_pendingConnectivityNotice) return false;
    _pendingConnectivityNotice = false;
    return true;
  }

  Future<void> restore() async {
    final access = await _tokenStorage.readAccessToken();
    _hasSession = access != null && access.isNotEmpty;
    _hydrated = true;
    notifyListeners();
  }

  /// Web BFF: reconcile in-memory session with API session cookie (same-origin web only).
  ///
  /// Do not call for split-host deployments; use [AuthCompletionService.completeFromTicket].
  /// Runs at most once per app launch. Connection errors set [consumeConnectivityNotice]
  /// so the shell can show [ConnectivitySnackBar] (probe is not tied to a user action).
  Future<void> syncWebCookieSession(AuthApi authApi) async {
    if (_webSessionSyncAttempted) return;
    _webSessionSyncAttempted = true;
    try {
      await authApi.getSession();
      _pendingConnectivityNotice = false;
      if (!_hasSession) {
        setAuthenticatedFromCookie();
      }
    } on DioException catch (e) {
      if (isConnectivityDioException(e)) {
        _pendingConnectivityNotice = true;
        notifyListeners();
      }
      await _handleSessionProbeFailure();
    } catch (_) {
      await _handleSessionProbeFailure();
    }
  }

  Future<void> _handleSessionProbeFailure() async {
    if (_hasSession) {
      final access = await _tokenStorage.readAccessToken();
      if (access == null || access.isEmpty) {
        await signOut();
      }
    }
  }

  Future<void> setAuthenticated({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _tokenStorage.writeTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    _hasSession = true;
    notifyListeners();
  }

  /// Web BFF: session cookie on API host; no JWT in secure storage.
  void setAuthenticatedFromCookie() {
    _hasSession = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _tokenStorage.clear();
    _hasSession = false;
    notifyListeners();
  }
}
