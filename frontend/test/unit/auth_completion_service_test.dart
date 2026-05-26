import 'package:felloway_client/app/auth/auth_session.dart';
import 'package:felloway_client/features/auth/application/auth_completion_service.dart';
import 'package:felloway_client/features/auth/data/auth_api.dart';
import 'package:felloway_client/features/auth/data/token_storage.dart';
import 'package:felloway_client/features/auth/domain/web_auth_mode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveWebAuthMode', () {
    test('different API host → splitHostJwt', () {
      expect(
        resolveWebAuthMode('https://dwkne2w3ldk1d.cloudfront.net'),
        WebAuthMode.splitHostJwt,
      );
    });
  });

  group('AuthCompletionService', () {
    late TokenStorage storage;
    late AuthSession session;

    setUp(() {
      storage = TokenStorage();
      session = AuthSession(tokenStorage: storage);
    });

    test('split-host: shouldProbeCookieSession is false', () {
      final service = AuthCompletionService(
        authApi: AuthApi(baseUrl: 'https://api.example.com'),
        authSession: session,
        webAuthMode: WebAuthMode.splitHostJwt,
      );
      expect(service.shouldProbeCookieSession, isFalse);
    });

    test('split-host: probeCookieSession returns notApplicable without getSession',
        () async {
      final service = AuthCompletionService(
        authApi: AuthApi(baseUrl: 'https://api.example.com'),
        authSession: session,
        webAuthMode: WebAuthMode.splitHostJwt,
      );
      final result = await service.probeCookieSession();
      expect(result, AuthCompletionResult.notApplicable);
      expect(session.isAuthenticated, isFalse);
    });

    test('same-origin: shouldProbeCookieSession is true', () {
      final service = AuthCompletionService(
        authApi: AuthApi(baseUrl: 'https://localhost:7086'),
        authSession: session,
        webAuthMode: WebAuthMode.sameOriginCookie,
      );
      expect(service.shouldProbeCookieSession, isTrue);
    });
  });

  group('useWebCookieAuth', () {
    test('split-host web does not use cookies', () {
      expect(
        useWebCookieAuth(
          isWeb: true,
          useMockApi: false,
          webAuthMode: WebAuthMode.splitHostJwt,
        ),
        isFalse,
      );
    });

    test('same-origin web uses cookies', () {
      expect(
        useWebCookieAuth(
          isWeb: true,
          useMockApi: false,
          webAuthMode: WebAuthMode.sameOriginCookie,
        ),
        isTrue,
      );
    });
  });
}
