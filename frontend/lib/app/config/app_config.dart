import 'package:flutter/foundation.dart';

/// Runtime configuration from `--dart-define` (see deployed-env quickstart).
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.streamApiKey,
    this.oauthIssuer,
    this.oauthClientId,
    this.oauthRedirectUrl,
    this.oauthDiscoveryUrl,
  });

  final String apiBaseUrl;
  final String streamApiKey;
  final String? oauthIssuer;
  final String? oauthClientId;
  final String? oauthRedirectUrl;
  final String? oauthDiscoveryUrl;

  AppConfig copyWith({
    String? apiBaseUrl,
    String? streamApiKey,
    String? oauthIssuer,
    String? oauthClientId,
    String? oauthRedirectUrl,
    String? oauthDiscoveryUrl,
  }) {
    return AppConfig(
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      streamApiKey: streamApiKey ?? this.streamApiKey,
      oauthIssuer: oauthIssuer ?? this.oauthIssuer,
      oauthClientId: oauthClientId ?? this.oauthClientId,
      oauthRedirectUrl: oauthRedirectUrl ?? this.oauthRedirectUrl,
      oauthDiscoveryUrl: oauthDiscoveryUrl ?? this.oauthDiscoveryUrl,
    );
  }

  static AppConfig fromEnvironment() {
    const api = String.fromEnvironment('API_BASE_URL', defaultValue: '');
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
    return AppConfig(
      apiBaseUrl: api,
      streamApiKey: streamKey,
      oauthIssuer: issuer.isEmpty ? null : issuer,
      oauthClientId: clientId.isEmpty ? null : clientId,
      oauthRedirectUrl: redirect,
      oauthDiscoveryUrl: discovery.isEmpty ? null : discovery,
    );
  }

  /// LinkedIn Developer Portal redirect URI (BFF callback on API host only).
  static String linkedInBffCallbackUriForApi(String apiBaseUrl) {
    final normalized = apiBaseUrl.replaceAll(RegExp(r'/+$'), '');
    if (normalized.isEmpty) {
      throw StateError('API_BASE_URL is required to build LinkedIn callback URI');
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
}
