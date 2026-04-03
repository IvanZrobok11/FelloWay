import 'package:felloway_client/features/chats/domain/chat_access_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatAccessPolicy', () {
    test('scoped channel requires membership', () {
      expect(
        ChatAccessPolicy.canAccessScopedChannel(hasMembership: true),
        isTrue,
      );
      expect(
        ChatAccessPolicy.canAccessScopedChannel(hasMembership: false),
        isFalse,
      );
    });

    test('event-scoped DM composer enabled only while attending', () {
      expect(
        ChatAccessPolicy.isEventScopedDmComposerEnabled(
          currentUserAttendsEvent: true,
        ),
        isTrue,
      );
      expect(
        ChatAccessPolicy.isEventScopedDmComposerEnabled(
          currentUserAttendsEvent: false,
        ),
        isFalse,
      );
    });
  });
}
