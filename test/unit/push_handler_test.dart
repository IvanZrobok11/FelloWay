import 'package:felloway_client/app/notifications/push_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PushHandler.routeForData', () {
    test('parses deepLink path', () {
      expect(PushHandler.routeForData({'deepLink': '/event/e1'}), '/event/e1');
    });

    test('parses eventId', () {
      expect(PushHandler.routeForData({'eventId': 'abc'}), '/event/abc');
    });

    test('parses channel type and id', () {
      expect(
        PushHandler.routeForData({
          'channelType': 'messaging',
          'channelId': 'trip_1',
        }),
        contains('/chats/channel'),
      );
      expect(
        PushHandler.routeForData({
          'channelType': 'messaging',
          'channelId': 'trip_1',
        }),
        contains('trip_1'),
      );
    });

    test('returns null when nothing matches', () {
      expect(PushHandler.routeForData({}), isNull);
    });
  });
}
