import 'package:felloway_client/app/app.dart';
import 'package:felloway_client/app/auth/auth_session.dart';
import 'package:felloway_client/app/config/app_config.dart';
import 'package:felloway_client/features/auth/data/auth_api.dart';
import '../test/helpers/auth_test_helpers.dart';
import 'package:felloway_client/features/auth/data/token_storage.dart';
import 'package:felloway_client/features/chats/application/chat_access_controller.dart';
import 'package:felloway_client/features/chats/data/stream_chat_service.dart';
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
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({'onboarding_complete_v1': true});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async {
          switch (call.method) {
            case 'read':
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

  testWidgets('signed-in user opens Chats tab and sees stream setup state', (
    tester,
  ) async {
    WidgetsFlutterBinding.ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    final onboarding = OnboardingPreferences(prefs);
    final draftStore = OnboardingDraftStore(prefs);
    const config = AppConfig(
      apiBaseUrl: 'https://api.example.com',
      streamApiKey: '',
    );
    final tokenStorage = TokenStorage();
    final authSession = AuthSession(tokenStorage: tokenStorage);
    await authSession.setAuthenticated(
      accessToken: 'it-access',
      refreshToken: 'it-refresh',
    );
    final authApi = AuthApi(baseUrl: config.apiBaseUrl);
    final authCompletion = testAuthCompletion(
      authApi: authApi,
      authSession: authSession,
    );
    final apiClient = ApiClient(config: config, tokenStorage: tokenStorage);
    final eventsRepository = EventsRepository(apiClient, config);
    final interestsRepository = InterestsRepository(apiClient);
    final usersRepository = UsersRepository(apiClient, config);
    final tripsRepository = TripsRepository(apiClient, config);
    final streamChatService = StreamChatService(
      config: config,
      apiClient: apiClient,
    );
    final chatAccessController = ChatAccessController();

    await tester.pumpWidget(
      FellowayApp(
        config: config,
        authSession: authSession,
        authApi: authApi,
        authCompletion: authCompletion,
        apiClient: apiClient,
        onboardingPreferences: onboarding,
        onboardingDraftStore: draftStore,
        interestsRepository: interestsRepository,
        eventsRepository: eventsRepository,
        usersRepository: usersRepository,
        tripsRepository: tripsRepository,
        streamChatService: streamChatService,
        chatAccessController: chatAccessController,
      ),
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(NavigationBar)),
    )!;
    await tester.tap(find.text(l10n.tabChats));
    await tester.pumpAndSettle();

    expect(find.text(l10n.chatsStreamKeyHint), findsOneWidget);
  });
}
