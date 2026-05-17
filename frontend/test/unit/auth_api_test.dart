import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:felloway_client/features/auth/data/auth_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exchangeLinkedIn parses TokenResponse', () async {
    final dio = Dio();
    dio.httpClientAdapter = _JsonAdapter({
      'accessToken': 'access-abc',
      'refreshToken': 'refresh-xyz',
      'expiresIn': 3600,
      'userId': 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    });
    final api = AuthApi(baseUrl: 'http://localhost:5161', dio: dio);
    final tokens = await api.exchangeLinkedIn(code: 'dev-smoke-user');
    expect(tokens.accessToken, 'access-abc');
    expect(tokens.refreshToken, 'refresh-xyz');
    expect(tokens.expiresIn, 3600);
    expect(tokens.userId, isNotEmpty);
  });

  test('refresh parses TokenResponse', () async {
    final dio = Dio();
    dio.httpClientAdapter = _JsonAdapter({
      'accessToken': 'new-access',
      'refreshToken': 'new-refresh',
      'expiresIn': 3600,
      'userId': 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    });
    final api = AuthApi(baseUrl: 'http://localhost:5161', dio: dio);
    final tokens = await api.refresh(refreshToken: 'old-refresh');
    expect(tokens.accessToken, 'new-access');
  });
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
