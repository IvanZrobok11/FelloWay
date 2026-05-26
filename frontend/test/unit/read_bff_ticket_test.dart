import 'package:felloway_client/features/auth/web/bff_ticket_from_browser_stub.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('readBffTicket prefers explicit uri query', () {
    final ticket = readBffTicket(
      uri: Uri.parse('https://web.example.com/auth/success?ticket=abc123'),
    );
    expect(ticket, 'abc123');
  });

  test('readBffTicket returns null when no ticket', () {
    expect(
      readBffTicket(uri: Uri.parse('https://web.example.com/auth/success')),
      isNull,
    );
  });
}
