import 'package:felloway_client/app/app_scope.dart';
import 'package:felloway_client/app/auth/auth_session.dart';
import 'package:felloway_client/app/config/app_config.dart';
import 'package:felloway_client/features/auth/data/auth_api.dart';
import 'package:felloway_client/features/auth/data/token_storage.dart';
import 'package:felloway_client/features/chats/application/chat_access_controller.dart';
import 'package:felloway_client/features/chats/data/stream_chat_service.dart';
import 'package:felloway_client/features/chats/presentation/chats_list_page.dart';
import 'package:felloway_client/features/events/data/events_repository.dart';
import 'package:felloway_client/features/onboarding/data/interests_repository.dart';
import 'package:felloway_client/features/onboarding/data/onboarding_draft_store.dart';
import 'package:felloway_client/features/onboarding/data/onboarding_preferences.dart';
import 'package:felloway_client/features/profile/data/users_repository.dart';
import 'package:felloway_client/features/trips/data/trips_repository.dart';
import 'package:felloway_client/l10n/app_localizations.dart';
import 'package:felloway_client/shared/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/auth_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async {
          switch (call.method) {
            case 'read':
              return null;
            case 'write':
            case 'delete':
            case 'deleteAll':
            case 'containsKey':
            case 'readAll':
              return null;
            default:
              return null;
          }
        });
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  Future<void> pumpChatsPage(
    WidgetTester tester, {
    required AuthSession authSession,
    required AppConfig config,
    required StreamChatService streamChatService,
  }) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete_v1': true});
    final prefs = await SharedPreferences.getInstance();
    final tokenStorage = TokenStorage();
    final apiClient = ApiClient(config: config, tokenStorage: tokenStorage);
    final authApi = AuthApi(baseUrl: config.apiBaseUrl);
    final authCompletion = testAuthCompletion(
      authApi: authApi,
      authSession: authSession,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: AppScope(
          config: config,
          authSession: authSession,
          authApi: authApi,
          authCompletion: authCompletion,
          apiClient: apiClient,
          onboardingPreferences: OnboardingPreferences(prefs),
          onboardingDraftStore: OnboardingDraftStore(prefs),
          interestsRepository: InterestsRepository(apiClient),
          eventsRepository: EventsRepository(apiClient, config),
          usersRepository: UsersRepository(apiClient, config),
          tripsRepository: TripsRepository(apiClient, config),
          streamChatService: streamChatService,
          chatAccessController: ChatAccessController(),
          child: const ChatsListPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('ChatsListPage shows guest message when not signed in', (
    tester,
  ) async {
    final authSession = AuthSession(tokenStorage: TokenStorage());
    await authSession.restore();
    const config = AppConfig(
      apiBaseUrl: 'https://test.local',
      streamApiKey: '',
    );
    final streamChatService = StreamChatService(
      config: config,
      apiClient: ApiClient(config: config, tokenStorage: TokenStorage()),
    );

    await pumpChatsPage(
      tester,
      authSession: authSession,
      config: config,
      streamChatService: streamChatService,
    );

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.chatsGuestMessage), findsOneWidget);
  });

  testWidgets(
    'ChatsListPage shows stream key hint when signed in without key',
    (tester) async {
      final authSession = AuthSession(tokenStorage: TokenStorage());
      await authSession.setAuthenticated(
        accessToken: 'test-access',
        refreshToken: 'test-refresh',
      );
      const config = AppConfig(
        apiBaseUrl: 'https://test.local',
        streamApiKey: '',
      );
      final apiClient = ApiClient(config: config, tokenStorage: TokenStorage());
      final usersRepository = UsersRepository(apiClient, config);
      final streamChatService = StreamChatService(
        config: config,
        apiClient: apiClient,
      );
      await streamChatService.syncWithSession(
        isAuthenticated: true,
        usersRepository: usersRepository,
      );

      await pumpChatsPage(
        tester,
        authSession: authSession,
        config: config,
        streamChatService: streamChatService,
      );

      final l10n = lookupAppLocalizations(const Locale('en'));
      expect(find.text(l10n.chatsStreamKeyHint), findsOneWidget);
    },
  );
}
