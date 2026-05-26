import 'package:felloway_client/app/router/resolve_post_sign_in_route.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolvePostSignInRoute', () {
    test('empty name routes to name onboarding', () {
      expect(resolvePostSignInRoute(''), '/onboarding/name');
      expect(resolvePostSignInRoute('   '), '/onboarding/name');
    });

    test('non-empty name routes to events', () {
      expect(resolvePostSignInRoute('Alex'), '/events');
      expect(resolvePostSignInRoute('  Alex  '), '/events');
    });

    test('profileHasDisplayName', () {
      expect(profileHasDisplayName(''), isFalse);
      expect(profileHasDisplayName('Jane'), isTrue);
    });
  });
}
