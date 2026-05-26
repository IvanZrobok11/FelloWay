import 'package:felloway_client/app/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

/// Verifies compile-time embedding of the Stream public key.
///
/// Run with:
/// `flutter test test/unit/app_config_stream_key_test.dart
///   --dart-define=STREAM_API_KEY=test-key`
const _compileTimeStreamKey = String.fromEnvironment('STREAM_API_KEY');

void main() {
  test('AppConfig.streamApiKey matches compile-time define', () {
    if (_compileTimeStreamKey.isEmpty) {
      fail(
        'Re-run with --dart-define=STREAM_API_KEY=test-key '
        'to verify CI embed pattern',
      );
    }
    final config = AppConfig.fromEnvironment();
    expect(config.streamApiKey, isNotEmpty);
    expect(config.streamApiKey, _compileTimeStreamKey);
  }, skip: _compileTimeStreamKey.isEmpty);
}
