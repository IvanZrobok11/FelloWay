import 'package:dio/dio.dart';

import '../../../shared/errors/app_failure.dart';
import '../../../shared/errors/result.dart';
import '../../../shared/network/api_client.dart';
import '../domain/user_profile.dart';
import '../domain/user_review.dart';

class PushPreferenceDraft {
  const PushPreferenceDraft({
    required this.globalEnabled,
    required this.eventMessages,
    required this.tripMessages,
    required this.directMessages,
  });

  final bool globalEnabled;
  final bool eventMessages;
  final bool tripMessages;
  final bool directMessages;

  Map<String, dynamic> toJson() => {
    'globalEnabled': globalEnabled,
    'eventMessages': eventMessages,
    'tripMessages': tripMessages,
    'directMessages': directMessages,
  };
}

class UsersRepository {
  UsersRepository(this._api);

  final ApiClient _api;

  Future<Result<UserProfile>> getMe() async {
    try {
      final res = await _api.dio.get<Map<String, dynamic>>('/users/me');
      final data = res.data;
      if (data == null) {
        return const Failure(ValidationFailure('Empty profile response'));
      }
      return Success(UserProfile.fromJson(data));
    } catch (e) {
      return Failure(_api.mapDioError(e));
    }
  }

  Future<Result<bool>> updateMe(UserProfile draft) async {
    try {
      await _api.dio.put<void>('/users/me', data: draft.toUpdateBody());
      return const Success(true);
    } on DioException catch (e) {
      return Failure(_api.mapDioError(e));
    }
  }

  Future<Result<bool>> blockUser(String userId) async {
    try {
      await _api.dio.post<void>('/users/$userId/block');
      return const Success(true);
    } on DioException catch (e) {
      return Failure(_api.mapDioError(e));
    }
  }

  Future<Result<List<UserReview>>> getUserReviews(String userId) async {
    try {
      final res = await _api.dio.get<Map<String, dynamic>>(
        '/users/$userId/reviews',
      );
      final data = res.data ?? const <String, dynamic>{};
      final raw =
          data['items'] as List<dynamic>? ??
          data['reviews'] as List<dynamic>? ??
          const [];
      final list = raw
          .map((e) => UserReview.fromJson(e as Map<String, dynamic>))
          .toList();
      return Success(list);
    } catch (e) {
      return Failure(_api.mapDioError(e));
    }
  }

  Future<Result<String?>> uploadAvatar(String filePath) async {
    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: 'avatar.jpg'),
      });
      final res = await _api.dio.post<Map<String, dynamic>>(
        '/users/me/avatar',
        data: form,
      );
      final url =
          res.data?['avatarUrl'] as String? ?? res.data?['url'] as String?;
      return Success(url);
    } on DioException catch (e) {
      return Failure(_api.mapDioError(e));
    }
  }

  /// Syncs toggles from [NotificationSettingsPage] when backend exposes prefs.
  Future<Result<bool>> syncPushPreferences(PushPreferenceDraft draft) async {
    try {
      await _api.dio.put<void>(
        '/users/me/push-preferences',
        data: draft.toJson(),
      );
      return const Success(true);
    } on DioException catch (e) {
      return Failure(_api.mapDioError(e));
    }
  }
}
