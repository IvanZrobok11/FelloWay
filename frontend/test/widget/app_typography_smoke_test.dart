import 'package:felloway_client/app/app.dart';
import 'package:felloway_client/app/auth/auth_session.dart';
import 'package:felloway_client/app/config/app_config.dart';
import 'package:felloway_client/app/theme/felloway_typography.dart';
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
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/auth_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async => null);
  });

  testWidgets('FellowayApp theme uses Onest font family', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete_v1': true});
    final prefs = await SharedPreferences.getInstance();
    const config = AppConfig(
      apiBaseUrl: 'https://test.local',
      streamApiKey: 'test-key',
    );
    final tokenStorage = TokenStorage();
    final authSession = AuthSession(tokenStorage: tokenStorage);
    final apiClient = ApiClient(config: config, tokenStorage: tokenStorage);

    await tester.pumpWidget(
      FellowayApp(
        config: config,
        authSession: authSession,
        authApi: AuthApi(baseUrl: config.apiBaseUrl),
        authCompletion: testAuthCompletion(
          authApi: AuthApi(baseUrl: config.apiBaseUrl),
          authSession: authSession,
        ),
        apiClient: apiClient,
        onboardingPreferences: OnboardingPreferences(prefs),
        onboardingDraftStore: OnboardingDraftStore(prefs),
        interestsRepository: InterestsRepository(apiClient),
        eventsRepository: EventsRepository(apiClient),
        usersRepository: UsersRepository(apiClient),
        tripsRepository: TripsRepository(apiClient),
        streamChatService: StreamChatService(
          config: config,
          apiClient: apiClient,
        ),
        chatAccessController: ChatAccessController(),
      ),
    );
    await tester.pump();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(
      materialApp.theme?.textTheme.bodyLarge?.fontFamily,
      FellowayTypography.fontFamily,
    );
  });
}
