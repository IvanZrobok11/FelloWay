import 'package:felloway_client/app/app_scope.dart';
import 'package:felloway_client/app/auth/auth_session.dart';
import 'package:felloway_client/app/config/api_mode.dart';
import 'package:felloway_client/app/config/app_config.dart';
import 'package:felloway_client/features/auth/data/auth_api.dart';
import 'package:felloway_client/features/auth/data/token_storage.dart';
import 'package:felloway_client/features/auth/presentation/oauth_sign_in_page.dart';
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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('live mode shows dev backend sign-in, not demo', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    const config = AppConfig(
      apiBaseUrl: 'http://localhost:5161',
      streamApiKey: '',
      apiMode: ApiMode.live,
    );
    final tokenStorage = TokenStorage();
    final authSession = AuthSession(tokenStorage: tokenStorage);
    final authApi = AuthApi(baseUrl: config.apiBaseUrl);
    final apiClient = ApiClient(config: config, tokenStorage: tokenStorage);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: AppScope(
          config: config,
          apiClient: apiClient,
          authApi: authApi,
          authSession: authSession,
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
          child: const OAuthSignInPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign in (local backend)'), findsOneWidget);
    expect(find.textContaining('Demo'), findsNothing);
  });
}
