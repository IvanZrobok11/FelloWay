import 'package:felloway_client/features/onboarding/domain/onboarding_completion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnboardingCompletion', () {
    test('is false when any mandatory field missing', () {
      expect(
        OnboardingCompletion.isSatisfied(
          displayName: '',
          interests: ['IT'],
          hobbies: 'music',
          homeCityLabel: 'Kyiv',
        ),
        isFalse,
      );
      expect(
        OnboardingCompletion.isSatisfied(
          displayName: 'Ann',
          interests: [],
          hobbies: 'music',
          homeCityLabel: 'Kyiv',
        ),
        isFalse,
      );
      expect(
        OnboardingCompletion.isSatisfied(
          displayName: 'Ann',
          interests: ['IT'],
          hobbies: '',
          homeCityLabel: 'Kyiv',
        ),
        isFalse,
      );
      expect(
        OnboardingCompletion.isSatisfied(
          displayName: 'Ann',
          interests: ['IT'],
          hobbies: 'music',
          homeCityLabel: '',
        ),
        isFalse,
      );
    });

    test('is true when all mandatory fields present', () {
      expect(
        OnboardingCompletion.isSatisfied(
          displayName: 'Ann',
          interests: ['IT'],
          hobbies: 'music',
          homeCityLabel: 'Kyiv',
        ),
        isTrue,
      );
    });
  });
}
