import 'package:dio/dio.dart';

import '../../app/config/app_config.dart';
import '../../features/auth/data/token_storage.dart';
import '../errors/app_failure.dart';

typedef UnauthorizedCallback = Future<void> Function();

/// HTTP client with bearer injection and 401 handling (refresh hook TBD).
class ApiClient {
  ApiClient({
    required AppConfig config,
    required TokenStorage tokenStorage,
    UnauthorizedCallback? onUnauthorized,
  }) : _tokenStorage = tokenStorage,
       _onUnauthorized = onUnauthorized {
    _dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  final TokenStorage _tokenStorage;
  final UnauthorizedCallback? _onUnauthorized;

  late final Dio _dio;

  Dio get dio => _dio;

  AppFailure mapDioError(Object e) {
    if (e is DioException) {
      final status = e.response?.statusCode;
      final msg = e.response?.data?.toString() ?? e.message ?? 'Network error';
      return NetworkFailure(status != null ? 'HTTP $status: $msg' : msg);
    }
    return NetworkFailure(e.toString());
  }
}
