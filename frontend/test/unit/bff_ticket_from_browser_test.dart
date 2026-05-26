import 'package:felloway_client/features/auth/web/bff_ticket_from_browser_stub.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('isCrossOriginApi detects different hosts', () {
    expect(
      isCrossOriginApi('https://api.example.com'),
      isNot(Uri.base.host),
    );
  });
}
