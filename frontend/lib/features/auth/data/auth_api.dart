import 'package:dio/dio.dart';

import '../../../shared/network/dio_credentials.dart';
import '../domain/token_response.dart';

/// Unauthenticated auth endpoints (OAuth exchange, refresh, BFF mobile complete).
class AuthApi {
  AuthApi({required String baseUrl, Dio? dio, bool sendCredentials = false})
    : _dio = dio ?? _createDio(baseUrl, sendCredentials: sendCredentials);

  final Dio _dio;

  static Dio _createDio(String baseUrl, {required bool sendCredentials}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );
    configureDioCredentials(dio, enabled: sendCredentials);
    return dio;
  }

  Future<TokenResponse> exchangeOAuth({
    required String provider,
    required String code,
    String redirectUri = 'http://localhost',
    String codeVerifier = 'dev',
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/oauth/$provider/token',
      data: {
        'code': code,
        'redirectUri': redirectUri,
        'codeVerifier': codeVerifier,
      },
    );
    return TokenResponse.fromJson(res.data ?? const {});
  }

  /// Redeems a one-time BFF ticket (mobile custom scheme or split-host web).
  Future<TokenResponse> completeBffTicket({required String ticket}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/linkedin/mobile/complete',
      data: {'ticket': ticket},
    );
    return TokenResponse.fromJson(res.data ?? const {});
  }

  @Deprecated('Use completeBffTicket')
  Future<TokenResponse> completeLinkedInMobile({required String ticket}) =>
      completeBffTicket(ticket: ticket);

  Future<Map<String, dynamic>?> getSession() async {
    final res = await _dio.get<Map<String, dynamic>>('/auth/session');
    return res.data;
  }

  Future<TokenResponse> exchangeLinkedIn({
    required String code,
    String redirectUri = 'http://localhost',
    String codeVerifier = 'dev',
  }) =>
      exchangeOAuth(
        provider: 'linkedin',
        code: code,
        redirectUri: redirectUri,
        codeVerifier: codeVerifier,
      );

  Future<TokenResponse> exchangeFacebook({
    required String code,
    String redirectUri = 'com.felloway.app:/oauthredirect',
    String codeVerifier = 'dev',
  }) =>
      exchangeOAuth(
        provider: 'facebook',
        code: code,
        redirectUri: redirectUri,
        codeVerifier: codeVerifier,
      );

  Future<TokenResponse> refresh({required String refreshToken}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return TokenResponse.fromJson(res.data ?? const {});
  }
}
