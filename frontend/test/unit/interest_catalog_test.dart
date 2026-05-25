import 'package:felloway_client/features/profile/domain/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UserProfile maps enriched interests to display labels', () {
    final profile = UserProfile.fromJson({
      'id': 'user-1',
      'displayName': 'Ann',
      'interestIds': [
        '11111111-1111-1111-1111-111111110001',
        '11111111-1111-1111-1111-111111110002',
      ],
      'interests': [
        {
          'id': '11111111-1111-1111-1111-111111110001',
          'name': 'ІТ та розробка',
          'sortOrder': 1,
        },
        {
          'id': '11111111-1111-1111-1111-111111110002',
          'name': 'Маркетинг/Продажі',
          'sortOrder': 2,
        },
      ],
    });

    expect(profile.interestLabels, ['ІТ та розробка', 'Маркетинг/Продажі']);
    expect(profile.interests, [
      '11111111-1111-1111-1111-111111110001',
      '11111111-1111-1111-1111-111111110002',
    ]);
  });
}
