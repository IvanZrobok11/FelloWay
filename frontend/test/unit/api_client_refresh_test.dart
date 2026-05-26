import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:felloway_client/app/config/app_config.dart';
import 'package:felloway_client/features/auth/data/auth_api.dart';
import 'package:felloway_client/features/auth/data/token_storage.dart';
import 'package:felloway_client/shared/network/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('401 triggers refresh and retries request once', () async {
    const config = AppConfig(
      apiBaseUrl: 'http://localhost:5161',
      streamApiKey: '',
    );
    final tokenStorage = _MemoryTokenStorage(
      access: 'expired',
      refresh: 'valid-refresh',
    );
    final authDio = Dio();
    authDio.httpClientAdapter = _JsonAdapter({
      'accessToken': 'fresh-access',
      'refreshToken': 'fresh-refresh',
      'expiresIn': 3600,
      'userId': 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    });
    final authApi = AuthApi(baseUrl: 'http://localhost:5161', dio: authDio);
    final client = ApiClient(
      config: config,
      tokenStorage: tokenStorage,
      authApi: authApi,
    );

    var calls = 0;
    client.dio.httpClientAdapter = _RefreshScenarioAdapter(
      onFetch: () {
        calls++;
        if (calls == 1) {
          return ResponseBody.fromString('Unauthorized', 401);
        }
        return ResponseBody.fromString(
          jsonEncode({'ok': true}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      },
    );

    final response = await client.dio.get<Map<String, dynamic>>('/users/me');
    expect(response.statusCode, 200);
    expect(calls, 2);
    expect(await tokenStorage.readAccessToken(), 'fresh-access');
  });

  test('web cookie mode still sends Bearer when JWT is stored', () async {
    const config = AppConfig(
      apiBaseUrl: 'http://localhost:5161',
      streamApiKey: 'test-key',
    );
    final tokenStorage = _MemoryTokenStorage(
      access: 'stored-jwt',
      refresh: 'stored-refresh',
    );
    final client = ApiClient(
      config: config,
      tokenStorage: tokenStorage,
      useCookieAuthOnWeb: true,
    );

    RequestOptions? captured;
    client.dio.httpClientAdapter = _CaptureAdapter(
      onFetch: (options) {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode({'id': 'u1', 'displayName': 'Test'}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      },
    );

    await client.dio.get<Map<String, dynamic>>('/users/me');
    expect(captured?.headers['Authorization'], 'Bearer stored-jwt');
  });
}

class _CaptureAdapter implements HttpClientAdapter {
  _CaptureAdapter({required this.onFetch});

  final ResponseBody Function(RequestOptions options) onFetch;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return onFetch(options);
  }
}

class _MemoryTokenStorage extends TokenStorage {
  _MemoryTokenStorage({required String access, required String refresh})
    : _access = access,
      _refresh = refresh;

  String _access;
  String _refresh;

  @override
  Future<String?> readAccessToken() async => _access;

  @override
  Future<String?> readRefreshToken() async => _refresh;

  @override
  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _access = accessToken;
    _refresh = refreshToken;
  }
}

class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter(this._body);

  final Map<String, dynamic> _body;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(_body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

class _RefreshScenarioAdapter implements HttpClientAdapter {
  _RefreshScenarioAdapter({required this.onFetch});

  final ResponseBody Function() onFetch;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return onFetch();
  }
}
