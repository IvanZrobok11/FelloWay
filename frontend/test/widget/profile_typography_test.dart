import 'package:felloway_client/app/app_scope.dart';
import 'package:felloway_client/app/auth/auth_session.dart';
import 'package:felloway_client/app/config/app_config.dart';
import 'package:felloway_client/app/theme/app_theme.dart';
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
import 'package:felloway_client/features/profile/presentation/profile_page.dart';
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

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async => null);
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  testWidgets('guest Profile message uses Onest', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    const config = AppConfig(
      apiBaseUrl: 'https://test.local',
      streamApiKey: 'test-key',
    );
    final tokenStorage = TokenStorage();
    final authSession = AuthSession(tokenStorage: tokenStorage);
    final apiClient = ApiClient(config: config, tokenStorage: tokenStorage);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
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
          authApi: AuthApi(baseUrl: config.apiBaseUrl),
          authCompletion: testAuthCompletion(
            authApi: AuthApi(baseUrl: config.apiBaseUrl),
            authSession: authSession,
          ),
          apiClient: apiClient,
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
          child: const ProfilePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final guestText = find.text(
      lookupAppLocalizations(const Locale('en')).profileGuestMessage,
    );
    expect(guestText, findsOneWidget);
    final style = tester.widget<Text>(guestText).style;
    expect(style?.fontFamily, FellowayTypography.fontFamily);
  });
}
