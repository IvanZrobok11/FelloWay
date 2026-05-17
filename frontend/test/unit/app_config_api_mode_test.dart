import 'package:felloway_client/app/config/api_mode.dart';
import 'package:felloway_client/app/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig.useMockApi', () {
    test('auto + example.com host uses mock', () {
      expect(
        const AppConfig(
          apiBaseUrl: 'https://api.example.com',
          streamApiKey: '',
        ).useMockApi,
        isTrue,
      );
    });

    test('auto + non-example host uses live', () {
      expect(
        const AppConfig(
          apiBaseUrl: 'https://staging.myapp.com',
          streamApiKey: '',
        ).useMockApi,
        isFalse,
      );
    });

    test('mock forces mock even with real-looking URL', () {
      expect(
        const AppConfig(
          apiBaseUrl: 'https://staging.myapp.com',
          streamApiKey: '',
          apiMode: ApiMode.mock,
        ).useMockApi,
        isTrue,
      );
    });

    test('live forces live even with example.com URL', () {
      expect(
        const AppConfig(
          apiBaseUrl: 'https://api.example.com',
          streamApiKey: '',
          apiMode: ApiMode.live,
        ).useMockApi,
        isFalse,
      );
    });
  });
}
