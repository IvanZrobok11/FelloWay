import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../app/config/app_config.dart';
import '../../features/auth/data/auth_api.dart';
import '../../features/auth/data/token_storage.dart';
import '../errors/app_failure.dart';
import 'dio_credentials.dart';
import 'error_response.dart';

typedef UnauthorizedCallback = Future<void> Function();

/// HTTP client with bearer injection, refresh-on-401, and error envelope parsing.
class ApiClient {
  ApiClient({
    required AppConfig config,
    required TokenStorage tokenStorage,
    AuthApi? authApi,
    UnauthorizedCallback? onUnauthorized,
    bool useCookieAuthOnWeb = false,
  }) : _tokenStorage = tokenStorage,
       _authApi = authApi,
       _onUnauthorized = onUnauthorized,
       _useCookieAuthOnWeb = useCookieAuthOnWeb {
    _dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );

    configureDioCredentials(_dio, enabled: kIsWeb && useCookieAuthOnWeb);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final useCookie = kIsWeb && _useCookieAuthOnWeb;
          if (!useCookie) {
            final token = await _tokenStorage.readAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final retried = error.requestOptions.extra['retried'] == true;
          final useCookie = kIsWeb && _useCookieAuthOnWeb;
          if (error.response?.statusCode == 401 && !retried && _authApi != null) {
            if (!useCookie) {
              try {
                final refreshed = await _refreshTokensOnce();
                if (refreshed) {
                  final opts = error.requestOptions;
                  opts.extra['retried'] = true;
                  final access = await _tokenStorage.readAccessToken();
                  if (access != null && access.isNotEmpty) {
                    opts.headers['Authorization'] = 'Bearer $access';
                  }
                  final response = await _dio.fetch<dynamic>(opts);
                  return handler.resolve(response);
                }
              } catch (_) {
                // fall through to sign-out
              }
            }
            await _onUnauthorized?.call();
          } else if (error.response?.statusCode == 401) {
            await _onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  final TokenStorage _tokenStorage;
  final AuthApi? _authApi;
  final UnauthorizedCallback? _onUnauthorized;
  final bool _useCookieAuthOnWeb;

  late final Dio _dio;
  Future<bool>? _refreshInFlight;

  Dio get dio => _dio;

  Future<bool> _refreshTokensOnce() async {
    if (_refreshInFlight != null) {
      return _refreshInFlight!;
    }
    _refreshInFlight = _doRefresh();
    try {
      return await _refreshInFlight!;
    } finally {
      _refreshInFlight = null;
    }
  }

  Future<bool> _doRefresh() async {
    final authApi = _authApi;
    if (authApi == null) return false;
    final refresh = await _tokenStorage.readRefreshToken();
    if (refresh == null || refresh.isEmpty) return false;
    final tokens = await authApi.refresh(refreshToken: refresh);
    if (tokens.accessToken.isEmpty) return false;
    await _tokenStorage.writeTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    return true;
  }

  AppFailure mapDioError(Object e) {
    if (e is DioException) {
      final status = e.response?.statusCode;
      final parsed = ErrorResponse.tryParse(e.response?.data);
      if (parsed != null) {
        return NetworkFailure(
          status != null
              ? 'HTTP $status: ${parsed.displayMessage}'
              : parsed.displayMessage,
        );
      }
      final msg = e.response?.data?.toString() ?? e.message ?? 'Network error';
      return NetworkFailure(status != null ? 'HTTP $status: $msg' : msg);
    }
    return NetworkFailure(e.toString());
  }
}
