import 'app_config.dart';

const _streamApiKeyOptional = bool.fromEnvironment(
  'STREAM_API_KEY_OPTIONAL',
  defaultValue: false,
);

/// Loads [AppConfig] from `--dart-define` (required for deployed web builds).
Future<AppConfig> loadAppConfig() async {
  final config = AppConfig.fromEnvironment();

  if (!_streamApiKeyOptional && config.streamApiKey.trim().isEmpty) {
    throw StateError(
      'STREAM_API_KEY is required. '
      'For dev/test/prod web, set GitHub variable '
      'DEV_/TEST_/PROD_STREAM_API_KEY and pass '
      '--dart-define=STREAM_API_KEY=... at flutter build web. '
      'Do not rely on env.json on the host.',
    );
  }

  return config;
}
