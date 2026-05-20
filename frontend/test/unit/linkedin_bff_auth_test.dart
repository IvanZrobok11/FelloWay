import 'package:flutter_test/flutter_test.dart';
import 'package:felloway_client/features/auth/mobile/linkedin_bff_auth.dart';

void main() {
  group('LinkedIn BFF mobile callback parsing', () {
    test('parses ticket from callback URI', () {
      final uri = Uri.parse('com.felloway.app://auth/callback?ticket=abc123');
      final error = uri.queryParameters['error'];
      expect(error, isNull);
      expect(uri.queryParameters['ticket'], 'abc123');
    });

    test('parses error from callback URI', () {
      final uri = Uri.parse('com.felloway.app://auth/callback?error=denied');
      expect(uri.queryParameters['error'], 'denied');
    });
  });
}
