import '../web/bff_ticket_from_browser.dart';

/// How Flutter web authenticates against the API for the current deployment.
enum WebAuthMode {
  /// Web and API on different hosts: ticket handoff → JWT Bearer (no cookie session).
  splitHostJwt,

  /// Same host or local dev: optional HttpOnly session cookie via credentialed calls.
  sameOriginCookie,
}

/// Resolves [WebAuthMode] from API base URL vs current page origin (web only).
WebAuthMode resolveWebAuthMode(String apiBaseUrl) {
  if (apiBaseUrl.isEmpty) {
    return WebAuthMode.sameOriginCookie;
  }
  return isCrossOriginApi(apiBaseUrl)
      ? WebAuthMode.splitHostJwt
      : WebAuthMode.sameOriginCookie;
}

/// Whether web should send credentialed cookies on API requests.
bool useWebCookieAuth({
  required bool isWeb,
  required bool useMockApi,
  required WebAuthMode webAuthMode,
}) {
  return isWeb && !useMockApi && webAuthMode == WebAuthMode.sameOriginCookie;
}
