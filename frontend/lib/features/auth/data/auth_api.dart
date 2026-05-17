import 'package:dio/dio.dart';

import '../domain/token_response.dart';

/// Unauthenticated auth endpoints (OAuth exchange, refresh).
class AuthApi {
  AuthApi({required String baseUrl, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
              headers: {'Accept': 'application/json'},
            ),
          );

  final Dio _dio;

  Future<TokenResponse> exchangeLinkedIn({
    required String code,
    String redirectUri = 'http://localhost',
    String codeVerifier = 'dev',
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/oauth/linkedin/token',
      data: {
        'code': code,
        'redirectUri': redirectUri,
        'codeVerifier': codeVerifier,
      },
    );
    return TokenResponse.fromJson(res.data ?? const {});
  }

  Future<TokenResponse> refresh({required String refreshToken}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return TokenResponse.fromJson(res.data ?? const {});
  }
}
