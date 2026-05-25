import 'package:felloway_client/app/auth/auth_session.dart';
import 'package:felloway_client/features/auth/data/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('setAuthenticatedFromCookie marks session without tokens', () {
    final session = AuthSession(tokenStorage: TokenStorage());
    session.setAuthenticatedFromCookie();
    expect(session.isAuthenticated, isTrue);
  });
}
