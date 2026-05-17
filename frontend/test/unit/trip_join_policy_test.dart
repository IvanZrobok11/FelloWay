import 'package:felloway_client/features/trips/domain/trip_join_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TripJoinPolicy', () {
    test('expectAutoApprove when normalized cities match', () {
      expect(
        TripJoinPolicy.expectAutoApprove(
          requesterHomeCity: ' Kyiv ',
          tripTargetCity: 'kyiv',
        ),
        isTrue,
      );
    });

    test('expectAutoApprove false when cities differ', () {
      expect(
        TripJoinPolicy.expectAutoApprove(
          requesterHomeCity: 'Lviv',
          tripTargetCity: 'Kyiv',
        ),
        isFalse,
      );
    });

    test('expectAutoApprove false when either city empty', () {
      expect(
        TripJoinPolicy.expectAutoApprove(
          requesterHomeCity: '',
          tripTargetCity: 'Kyiv',
        ),
        isFalse,
      );
    });

    test('isLowRatingWarning below threshold', () {
      expect(TripJoinPolicy.isLowRatingWarning(3.4), isTrue);
      expect(TripJoinPolicy.isLowRatingWarning(3.5), isFalse);
      expect(TripJoinPolicy.isLowRatingWarning(null), isFalse);
    });
  });
}
