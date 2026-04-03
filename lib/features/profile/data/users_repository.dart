import 'package:dio/dio.dart';

import '../../../shared/errors/app_failure.dart';
import '../../../shared/errors/result.dart';
import '../../../shared/network/api_client.dart';
import '../domain/user_profile.dart';

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
}
