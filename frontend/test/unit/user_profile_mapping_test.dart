import 'dart:convert';
import 'dart:io';

import 'package:felloway_client/features/profile/domain/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Map<String, dynamic> backendJson;

  setUpAll(() {
    final raw = File(
      'test/fixtures/user_profile_backend.json',
    ).readAsStringSync();
    backendJson = jsonDecode(raw) as Map<String, dynamic>;
  });

  test('fromJson reads contract fields from backend fixture', () {
    final profile = UserProfile.fromJson(backendJson);
    expect(profile.displayName, 'Smoke User');
    expect(profile.homeCityLabel, 'Kyiv');
    expect(profile.homeCityId, 'b2c3d4e5-f6a7-8901-bcde-f12345678901');
    expect(profile.interests, hasLength(1));
    expect(profile.ratingAverage, 4.5);
  });

  test('toUpdateBody uses UserProfileUpdate shape', () {
    final profile = UserProfile(
      id: backendJson['id'] as String,
      displayName: 'Updated',
      bio: 'Bio',
      homeCityId: 'b2c3d4e5-f6a7-8901-bcde-f12345678901',
      interests: ['c3d4e5f6-a7b8-9012-cdef-123456789012'],
    );
    final body = profile.toUpdateBody();
    expect(body['displayName'], 'Updated');
    expect(body['bio'], 'Bio');
    expect(body['homeCityId'], 'b2c3d4e5-f6a7-8901-bcde-f12345678901');
    expect(body['interestIds'], ['c3d4e5f6-a7b8-9012-cdef-123456789012']);
    expect(body.containsKey('homeCity'), isFalse);
  });
}
