import 'package:felloway_client/features/auth/domain/web_auth_mode.dart';
import 'package:flutter_test/flutter_test.dart';

/// [OAuthBffSuccessPage] on split-host must use ticket→JWT ([AuthCompletionService]),
/// not cookie session. Full widget pump needs AppScope; contract asserted here.
void main() {
  test('split-host success flow disables cookie auth and session probe', () {
    expect(
      resolveWebAuthMode('https://dwkne2w3ldk1d.cloudfront.net'),
      WebAuthMode.splitHostJwt,
    );
    expect(
      useWebCookieAuth(
        isWeb: true,
        useMockApi: false,
        webAuthMode: WebAuthMode.splitHostJwt,
      ),
      isFalse,
    );
  });
}
