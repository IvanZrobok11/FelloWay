import 'package:felloway_client/app/app.dart';
import 'package:felloway_client/app/auth/auth_session.dart';
import 'package:felloway_client/app/config/api_mode.dart';
import 'package:felloway_client/app/config/app_config.dart';
import 'package:felloway_client/features/auth/data/auth_api.dart';
import 'package:felloway_client/features/auth/data/token_storage.dart';
import 'package:felloway_client/features/chats/application/chat_access_controller.dart';
import 'package:felloway_client/features/chats/data/stream_chat_service.dart';
import 'package:felloway_client/features/events/data/events_repository.dart';
import 'package:felloway_client/features/onboarding/data/onboarding_draft_store.dart';
import 'package:felloway_client/features/onboarding/data/onboarding_preferences.dart';
import 'package:felloway_client/features/profile/data/users_repository.dart';
import 'package:felloway_client/features/trips/data/trips_repository.dart';
import 'package:felloway_client/shared/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  testWidgets('app loads shell with bottom navigation', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final onboarding = OnboardingPreferences(prefs);
    final draftStore = OnboardingDraftStore(prefs);
    final tokenStorage = TokenStorage();
    final authSession = AuthSession(tokenStorage: tokenStorage);
    await authSession.restore();
    const config = AppConfig(
      apiBaseUrl: 'https://test.local',
      streamApiKey: '',
      apiMode: ApiMode.mock,
    );
    final authApi = AuthApi(baseUrl: config.apiBaseUrl);
    final apiClient = ApiClient(config: config, tokenStorage: tokenStorage);
    final eventsRepository = EventsRepository(apiClient, config);
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
        apiClient: apiClient,
        onboardingPreferences: onboarding,
        onboardingDraftStore: draftStore,
        eventsRepository: eventsRepository,
        usersRepository: usersRepository,
        tripsRepository: tripsRepository,
        streamChatService: streamChatService,
        chatAccessController: chatAccessController,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
