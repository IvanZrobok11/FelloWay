import 'package:flutter/foundation.dart';

import 'api_mode.dart';

/// Runtime configuration from `--dart-define` (see
/// [specs/001-event-networking-app/quickstart.md]).
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.streamApiKey,
    this.oauthIssuer,
    this.oauthClientId,
    this.oauthRedirectUrl,
    this.oauthDiscoveryUrl,
    this.apiMode = ApiMode.auto,
  });

  final String apiBaseUrl;
  final String streamApiKey;
  final String? oauthIssuer;
  final String? oauthClientId;
  final String? oauthRedirectUrl;
  final String? oauthDiscoveryUrl;

  /// Explicit mode from `--dart-define=API_MODE=mock|live` or [ApiMode.auto].
  final ApiMode apiMode;

  /// Whether REST (and Stream token path) should use in-app stubs instead of
  /// the network.
  bool get useMockApi {
    switch (apiMode) {
      case ApiMode.mock:
        return true;
      case ApiMode.live:
        return false;
      case ApiMode.auto:
        return apiBaseUrl.contains('example.com');
    }
  }

  /// Legacy name: same as [useMockApi].
  @Deprecated('Use useMockApi')
  bool get isDemoBackend => useMockApi;

  AppConfig copyWith({
    String? apiBaseUrl,
    String? streamApiKey,
    String? oauthIssuer,
    String? oauthClientId,
    String? oauthRedirectUrl,
    String? oauthDiscoveryUrl,
    ApiMode? apiMode,
  }) {
    return AppConfig(
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      streamApiKey: streamApiKey ?? this.streamApiKey,
      oauthIssuer: oauthIssuer ?? this.oauthIssuer,
      oauthClientId: oauthClientId ?? this.oauthClientId,
      oauthRedirectUrl: oauthRedirectUrl ?? this.oauthRedirectUrl,
      oauthDiscoveryUrl: oauthDiscoveryUrl ?? this.oauthDiscoveryUrl,
      apiMode: apiMode ?? this.apiMode,
    );
  }

  static AppConfig fromEnvironment() {
    const api = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.example.com',
    );
    const streamKey = String.fromEnvironment(
      'STREAM_API_KEY',
      defaultValue: '',
    );
    const issuer = String.fromEnvironment('OAUTH_ISSUER', defaultValue: '');
    const clientId = String.fromEnvironment(
      'OAUTH_CLIENT_ID',
      defaultValue: '',
    );
    const redirectFromEnv = String.fromEnvironment(
      'OAUTH_REDIRECT_URL',
      defaultValue: '',
    );
    final redirect = redirectFromEnv.isNotEmpty
        ? redirectFromEnv
        : (kIsWeb
            ? oauthRedirectUriForApi(api)
            : 'com.felloway.app:/oauthredirect');
    const discovery = String.fromEnvironment(
      'OAUTH_DISCOVERY_URL',
      defaultValue: '',
    );
    const apiModeRaw = String.fromEnvironment('API_MODE', defaultValue: '');
    return AppConfig(
      apiBaseUrl: api,
      streamApiKey: streamKey,
      oauthIssuer: issuer.isEmpty ? null : issuer,
      oauthClientId: clientId.isEmpty ? null : clientId,
      oauthRedirectUrl: redirect,
      oauthDiscoveryUrl: discovery.isEmpty ? null : discovery,
      apiMode: _parseApiMode(apiModeRaw),
    );
  }

  /// LinkedIn Developer Portal redirect URI (BFF callback on API host only).
  ///
  /// Register e.g. `https://localhost:7086/auth/linkedin/callback` (LinkedIn Developer Portal).
  static String linkedInBffCallbackUriForApi(String apiBaseUrl) {
    final normalized = apiBaseUrl.replaceAll(RegExp(r'/+$'), '');
    if (normalized.isEmpty || normalized.contains('example.com')) {
      return 'https://localhost:7086/auth/linkedin/callback';
    }
    return '$normalized/auth/linkedin/callback';
  }

  /// BFF login entry (opens server Challenge; not a client OAuth redirect).
  static Uri linkedInBffLoginUri(String apiBaseUrl, {required String returnUrl}) {
    return Uri.parse(apiBaseUrl).replace(
      path: '/auth/linkedin/login',
      queryParameters: {'platform': 'web', 'returnUrl': returnUrl},
    );
  }

  @Deprecated('Use linkedInBffCallbackUriForApi')
  static String oauthRedirectUriForApi(String apiBaseUrl) =>
      linkedInBffCallbackUriForApi(apiBaseUrl);

  static ApiMode _parseApiMode(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'mock':
        return ApiMode.mock;
      case 'live':
        return ApiMode.live;
      default:
        return ApiMode.auto;
    }
  }
}
