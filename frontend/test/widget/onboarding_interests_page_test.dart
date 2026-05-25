import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:felloway_client/app/app_scope.dart';
import 'package:felloway_client/app/auth/auth_session.dart';
import 'package:felloway_client/app/config/api_mode.dart';
import 'package:felloway_client/app/config/app_config.dart';
import 'package:felloway_client/features/auth/data/auth_api.dart';
import 'package:felloway_client/features/auth/data/token_storage.dart';
import 'package:felloway_client/features/chats/application/chat_access_controller.dart';
import 'package:felloway_client/features/chats/data/stream_chat_service.dart';
import 'package:felloway_client/features/events/data/events_repository.dart';
import 'package:felloway_client/features/onboarding/data/interests_repository.dart';
import 'package:felloway_client/features/onboarding/data/onboarding_draft_store.dart';
import 'package:felloway_client/features/onboarding/data/onboarding_preferences.dart';
import 'package:felloway_client/features/onboarding/presentation/interests_page.dart';
import 'package:felloway_client/features/profile/data/users_repository.dart';
import 'package:felloway_client/features/trips/data/trips_repository.dart';
import 'package:felloway_client/l10n/app_localizations.dart';
import 'package:felloway_client/shared/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  testWidgets('InterestsPage shows ten catalog chips from GET /interests', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final fixture =
        jsonDecode(
              File('test/fixtures/interests_catalog_backend.json').readAsStringSync(),
            )
            as Map<String, dynamic>;
    const config = AppConfig(
      apiBaseUrl: 'http://localhost:5161',
      streamApiKey: '',
      apiMode: ApiMode.live,
    );
    final tokenStorage = TokenStorage();
    final authApi = AuthApi(baseUrl: config.apiBaseUrl);
    final apiClient = ApiClient(config: config, tokenStorage: tokenStorage);
    apiClient.dio.httpClientAdapter = _InterestsFixtureAdapter(fixture);

    await tester.pumpWidget(
      MaterialApp.router(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: GoRouter(
          initialLocation: '/onboarding/interests',
          routes: [
            GoRoute(
              path: '/onboarding/interests',
              builder: (context, state) => const InterestsPage(),
            ),
          ],
        ),
        builder: (context, child) {
          return AppScope(
            config: config,
            apiClient: apiClient,
            authApi: authApi,
            authSession: AuthSession(tokenStorage: tokenStorage),
            onboardingPreferences: OnboardingPreferences(prefs),
            onboardingDraftStore: OnboardingDraftStore(prefs),
            interestsRepository: InterestsRepository(apiClient),
            eventsRepository: EventsRepository(apiClient, config),
            usersRepository: UsersRepository(apiClient, config),
            tripsRepository: TripsRepository(apiClient, config),
            streamChatService: StreamChatService(
              config: config,
              apiClient: apiClient,
            ),
            chatAccessController: ChatAccessController(),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byType(FilterChip), findsNWidgets(10));
    expect(find.text('ІТ та розробка'), findsOneWidget);
    expect(find.text('Мілітарі'), findsOneWidget);
  });
}

class _InterestsFixtureAdapter implements HttpClientAdapter {
  _InterestsFixtureAdapter(this._body);

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
