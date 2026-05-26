import 'package:felloway_client/features/auth/domain/web_auth_mode.dart';
import 'package:felloway_client/features/auth/web/bff_ticket_from_browser_stub.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('isCrossOriginApi detects different hosts', () {
    expect(
      isCrossOriginApi('https://api.example.com'),
      isNot(Uri.base.host),
    );
  });

  test('prod-like CloudFront API host is cross-origin', () {
    expect(
      isCrossOriginApi('https://dwkne2w3ldk1d.cloudfront.net'),
      isTrue,
    );
    expect(
      resolveWebAuthMode('https://dwkne2w3ldk1d.cloudfront.net'),
      WebAuthMode.splitHostJwt,
    );
  });
}
