import 'package:felloway_client/app/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('linkedInBffCallbackUriForApi uses HTTPS local default', () {
    expect(
      AppConfig.linkedInBffCallbackUriForApi('https://api.example.com'),
      'https://localhost:7086/auth/linkedin/callback',
    );
    expect(
      AppConfig.linkedInBffCallbackUriForApi('https://localhost:7086'),
      'https://localhost:7086/auth/linkedin/callback',
    );
  });

  test('linkedInBffLoginUri builds server login entry', () {
    final uri = AppConfig.linkedInBffLoginUri(
      'https://localhost:7086',
      returnUrl: 'https://localhost:7357',
    );
    expect(uri.scheme, 'https');
    expect(uri.path, '/auth/linkedin/login');
    expect(uri.queryParameters['platform'], 'web');
    expect(uri.queryParameters['returnUrl'], 'https://localhost:7357');
  });
}
