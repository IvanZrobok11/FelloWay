import 'package:felloway_client/app/app_scope.dart';
import 'package:felloway_client/app/auth/auth_session.dart';
import 'package:felloway_client/app/config/app_config.dart';
import 'package:felloway_client/features/auth/data/auth_api.dart';
import '../helpers/auth_test_helpers.dart';
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

  testWidgets('sign-in shows LinkedIn only (no demo or local backend)', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    const config = AppConfig(
      apiBaseUrl: 'https://dev.api.example.com',
      streamApiKey: '',
    );
    final tokenStorage = TokenStorage();
    final authSession = AuthSession(tokenStorage: tokenStorage);
    final authApi = AuthApi(baseUrl: config.apiBaseUrl);
    final authCompletion = testAuthCompletion(
      authApi: authApi,
      authSession: authSession,
    );
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
          authCompletion: authCompletion,
          authSession: authSession,
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
          child: const OAuthSignInPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('LinkedIn'), findsWidgets);
    expect(find.text('Sign in (local backend)'), findsNothing);
    expect(find.textContaining('Demo'), findsNothing);
  });
}
