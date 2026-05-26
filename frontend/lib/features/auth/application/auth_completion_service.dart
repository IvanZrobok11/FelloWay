import 'package:flutter/foundation.dart';

import '../../../app/auth/auth_session.dart';
import '../data/auth_api.dart';
import '../domain/token_response.dart';
import '../domain/web_auth_mode.dart';
import '../web/bff_ticket_from_browser.dart';

/// Result of a post-login completion attempt (BFF ticket or cookie probe).
enum AuthCompletionResult {
  success,
  missingTokens,
  notApplicable,
  failed,
}

/// Orchestrates LinkedIn BFF post-login: ticket→JWT (split-host) or cookie probe (same-origin).
class AuthCompletionService {
  AuthCompletionService({
    required AuthApi authApi,
    required AuthSession authSession,
    required WebAuthMode webAuthMode,
  })  : _authApi = authApi,
        _authSession = authSession,
        _webAuthMode = webAuthMode;

  final AuthApi _authApi;
  final AuthSession _authSession;
  final WebAuthMode _webAuthMode;

  WebAuthMode get webAuthMode => _webAuthMode;

  /// Cookie session probe is only valid when web and API share an origin.
  bool get shouldProbeCookieSession =>
      _webAuthMode == WebAuthMode.sameOriginCookie;

  /// Redeems a one-time BFF ticket for FelloWay JWTs (web split-host and mobile).
  Future<AuthCompletionResult> completeFromTicket(String ticket) async {
    if (ticket.isEmpty) {
      return AuthCompletionResult.missingTokens;
    }
    try {
      final tokens = await _authApi.completeBffTicket(ticket: ticket);
      return await _persistTokens(tokens);
    } on Object {
      return AuthCompletionResult.failed;
    }
  }

  /// Probes API session cookie; only call when [shouldProbeCookieSession] is true.
  Future<AuthCompletionResult> probeCookieSession() async {
    if (!shouldProbeCookieSession) {
      return AuthCompletionResult.notApplicable;
    }
    await _authSession.syncWebCookieSession(_authApi);
    return _authSession.isAuthenticated
        ? AuthCompletionResult.success
        : AuthCompletionResult.failed;
  }

  Future<AuthCompletionResult> _persistTokens(TokenResponse tokens) async {
    if (tokens.accessToken.isEmpty) {
      return AuthCompletionResult.missingTokens;
    }
    await _authSession.setAuthenticated(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    if (kIsWeb) {
      clearBffTicketFromBrowserUrl();
    }
    return AuthCompletionResult.success;
  }
}
