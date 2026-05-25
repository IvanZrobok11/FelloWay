import 'package:felloway_client/app/app.dart';
import 'package:felloway_client/app/auth/auth_session.dart';
import 'package:felloway_client/app/config/app_config.dart';
import 'package:felloway_client/features/auth/data/auth_api.dart';
import 'package:felloway_client/features/auth/data/token_storage.dart';
import 'package:felloway_client/features/chats/application/chat_access_controller.dart';
import 'package:felloway_client/features/chats/data/stream_chat_service.dart';
import 'package:felloway_client/features/events/data/events_repository.dart';
import 'package:felloway_client/features/onboarding/data/interests_repository.dart';
import 'package:felloway_client/features/onboarding/data/onboarding_draft_store.dart';
import 'package:felloway_client/features/onboarding/data/onboarding_preferences.dart';
import 'package:felloway_client/features/profile/data/users_repository.dart';
import 'package:felloway_client/features/trips/data/trips_repository.dart';
import 'package:felloway_client/shared/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app shows main navigation shell', (tester) async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final onboarding = OnboardingPreferences(prefs);
    final draftStore = OnboardingDraftStore(prefs);
    final config = AppConfig.fromEnvironment();
    final tokenStorage = TokenStorage();
    final authSession = AuthSession(tokenStorage: tokenStorage);
    await authSession.restore();
    final authApi = AuthApi(baseUrl: config.apiBaseUrl);
    final apiClient = ApiClient(
      config: config,
      tokenStorage: tokenStorage,
      authApi: authApi,
      onUnauthorized: authSession.signOut,
    );
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

    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
