import 'package:felloway_client/app/config/app_config.dart';
import 'package:felloway_client/app/config/app_config_loader.dart';
import 'package:flutter_test/flutter_test.dart';

/// Compile-time key when tests are run with
/// `--dart-define=STREAM_API_KEY=test-key`.
const _compileTimeStreamKey = String.fromEnvironment('STREAM_API_KEY');

const _streamApiKeyOptional = bool.fromEnvironment(
  'STREAM_API_KEY_OPTIONAL',
);

const _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

void main() {
  group('loadAppConfig', () {
    test('returns AppConfig when STREAM_API_KEY_OPTIONAL is true', () async {
      if (!_streamApiKeyOptional || _apiBaseUrl.isEmpty) {
        return;
      }
      final config = await loadAppConfig();
      expect(config, isA<AppConfig>());
      expect(config.apiBaseUrl, _apiBaseUrl);
    });

    test('empty key throws StateError citing dart-define not env.json', () {
      if (_streamApiKeyOptional || _compileTimeStreamKey.isNotEmpty) {
        return;
      }
      expect(
        loadAppConfig(),
        throwsA(
          predicate<StateError>(
            (e) =>
                e.message.contains('dart-define') &&
                e.message.contains('STREAM_API_KEY') &&
                e.message.contains('Do not rely on env.json'),
          ),
        ),
      );
    });

    test(
      'non-empty compile-time STREAM_API_KEY is present in AppConfig',
      () {
        expect(AppConfig.fromEnvironment().streamApiKey, _compileTimeStreamKey);
      },
      skip: _compileTimeStreamKey.isEmpty
          ? 'Run: flutter test --dart-define=STREAM_API_KEY=test-key'
          : false,
    );

    test('empty API_BASE_URL throws StateError citing dart-define', () {
      const apiUrl = String.fromEnvironment('API_BASE_URL');
      if (apiUrl.isNotEmpty) {
        return;
      }
      expect(
        loadAppConfig(),
        throwsA(
          predicate<StateError>(
            (e) =>
                e.message.contains('API_BASE_URL') &&
                e.message.contains('dart-define'),
          ),
        ),
      );
    });
  });
}
