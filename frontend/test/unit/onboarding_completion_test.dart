import 'package:felloway_client/features/onboarding/domain/onboarding_completion.dart';
import 'package:flutter_test/flutter_test.dart';

const _sampleInterestId = '11111111-1111-1111-1111-111111110001';

void main() {
  group('OnboardingCompletion', () {
    test('is false when any mandatory field missing', () {
      expect(
        OnboardingCompletion.isSatisfied(
          displayName: '',
          interests: [_sampleInterestId],
          homeCityLabel: 'Kyiv',
        ),
        isFalse,
      );
      expect(
        OnboardingCompletion.isSatisfied(
          displayName: 'Ann',
          interests: [],
          homeCityLabel: 'Kyiv',
        ),
        isFalse,
      );
      expect(
        OnboardingCompletion.isSatisfied(
          displayName: 'Ann',
          interests: [_sampleInterestId],
          homeCityLabel: '',
        ),
        isFalse,
      );
    });

    test('is true when all mandatory fields present', () {
      expect(
        OnboardingCompletion.isSatisfied(
          displayName: 'Ann',
          interests: [_sampleInterestId],
          homeCityLabel: 'Kyiv',
        ),
        isTrue,
      );
    });
  });
}
