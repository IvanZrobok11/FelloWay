import 'package:felloway_client/app/config/app_config.dart';
import 'package:felloway_client/app/config/app_config_loader.dart';
import 'package:flutter_test/flutter_test.dart';

/// Compile-time key when tests are run with
/// `--dart-define=STREAM_API_KEY=test-key`.
const _compileTimeStreamKey = String.fromEnvironment('STREAM_API_KEY');

const _streamApiKeyOptional = bool.fromEnvironment(
  'STREAM_API_KEY_OPTIONAL',
);

void main() {
  group('loadAppConfig', () {
    test('returns AppConfig when STREAM_API_KEY_OPTIONAL is true', () async {
      if (!_streamApiKeyOptional) {
        return;
      }
      final config = await loadAppConfig();
      expect(config, isA<AppConfig>());
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
  });
}
