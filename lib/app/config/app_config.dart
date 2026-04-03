/// Runtime configuration from `--dart-define` (see [specs/001-event-networking-app/quickstart.md]).
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

  bool get isDemoBackend => apiBaseUrl.contains('example.com');

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
    const redirect = String.fromEnvironment(
      'OAUTH_REDIRECT_URL',
      defaultValue: 'com.felloway.app:/oauthredirect',
    );
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
}
