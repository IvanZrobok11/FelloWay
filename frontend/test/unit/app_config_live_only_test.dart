import 'package:felloway_client/app/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig live-only', () {
    test('linkedInBffCallbackUriForApi uses API host', () {
      expect(
        AppConfig.linkedInBffCallbackUriForApi('https://dev.api.example.com'),
        'https://dev.api.example.com/auth/linkedin/callback',
      );
    });

    test('empty apiBaseUrl throws for callback URI', () {
      expect(
        () => AppConfig.linkedInBffCallbackUriForApi(''),
        throwsA(isA<StateError>()),
      );
    });
  });
}
