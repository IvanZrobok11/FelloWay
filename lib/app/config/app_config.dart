/// Runtime configuration from `--dart-define` (see [specs/001-event-networking-app/quickstart.md]).
class AppConfig {
  const AppConfig({required this.apiBaseUrl, required this.streamApiKey});

  final String apiBaseUrl;
  final String streamApiKey;

  static AppConfig fromEnvironment() {
    const api = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.example.com',
    );
    const streamKey = String.fromEnvironment(
      'STREAM_API_KEY',
      defaultValue: '',
    );
    return AppConfig(apiBaseUrl: api, streamApiKey: streamKey);
  }
}
