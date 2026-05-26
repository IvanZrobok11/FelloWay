import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:felloway_client/app/config/app_config.dart';
import 'package:felloway_client/features/auth/data/token_storage.dart';
import 'package:felloway_client/features/onboarding/data/interests_repository.dart';
import 'package:felloway_client/shared/errors/result.dart';
import 'package:felloway_client/shared/network/api_client.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async => null);
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  test('fetchCatalog parses GET /interests response', () async {
    final fixture =
        jsonDecode(
              File('test/fixtures/interests_catalog_backend.json').readAsStringSync(),
            )
            as Map<String, dynamic>;

    const config = AppConfig(
      apiBaseUrl: 'http://localhost:5161',
      streamApiKey: ''
    );
    final api = ApiClient(config: config, tokenStorage: TokenStorage());
    api.dio.httpClientAdapter = _FixtureAdapter(fixture);

    final repo = InterestsRepository(api);
    final result = await repo.fetchCatalog();

    expect(result, isA<Success>());
    final items = (result as Success).value;
    expect(items, hasLength(10));
    expect(items.first.name, 'ІТ та розробка');
    expect(items.last.sortOrder, 10);
  });
}

class _FixtureAdapter implements HttpClientAdapter {
  _FixtureAdapter(this._body);

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
