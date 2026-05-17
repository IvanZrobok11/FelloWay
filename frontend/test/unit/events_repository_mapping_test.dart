import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:felloway_client/app/config/api_mode.dart';
import 'package:felloway_client/app/config/app_config.dart';
import 'package:felloway_client/features/auth/data/token_storage.dart';
import 'package:felloway_client/features/events/data/events_repository.dart';
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

  test('listEvents maps items and nextCursor from backend fixture', () async {
    final fixture =
        jsonDecode(
              File(
                'test/fixtures/event_list_page_backend.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;

    const config = AppConfig(
      apiBaseUrl: 'http://localhost:5161',
      streamApiKey: '',
      apiMode: ApiMode.live,
    );
    final tokenStorage = TokenStorage();
    final api = ApiClient(config: config, tokenStorage: tokenStorage);
    api.dio.httpClientAdapter = _FixtureAdapter(fixture);

    final repo = EventsRepository(api, config);
    final result = await repo.listEvents();

    expect(result, isA<Success>());
    final page = (result as Success).value;
    expect(page.items, hasLength(1));
    expect(page.items.first.title, 'Flutter & Friends Kyiv');
    expect(page.items.first.city, 'Kyiv');
    expect(page.nextCursor, isNull);
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
