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
import 'package:felloway_client/features/onboarding/data/onboarding_draft_store.dart';
import 'package:felloway_client/features/onboarding/data/onboarding_preferences.dart';
import 'package:felloway_client/features/profile/data/users_repository.dart';
import 'package:felloway_client/features/trips/data/trips_repository.dart';
import 'package:felloway_client/l10n/app_localizations.dart';
import 'package:felloway_client/shared/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Widget> _app({
  required AppConfig config,
  required AuthSession session,
  required String initialLocation,
  required Widget child,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final tokenStorage = TokenStorage();
  final authApi = AuthApi(baseUrl: config.apiBaseUrl);
  final apiClient = ApiClient(config: config, tokenStorage: tokenStorage);
  return MaterialApp.router(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/sign-in',
          builder: (context, state) => child,
        ),
      ],
    ),
    builder: (context, widget) {
      return AppScope(
        config: config,
        apiClient: apiClient,
        authApi: authApi,
        authSession: session,
        onboardingPreferences: OnboardingPreferences(prefs),
        onboardingDraftStore: OnboardingDraftStore(prefs),
        eventsRepository: EventsRepository(apiClient, config),
        usersRepository: UsersRepository(apiClient, config),
        tripsRepository: TripsRepository(apiClient, config),
        streamChatService: StreamChatService(
          config: config,
          apiClient: apiClient,
        ),
        chatAccessController: ChatAccessController(),
        child: widget ?? const SizedBox.shrink(),
      );
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('live mode shows LinkedIn BFF button', (tester) async {
    const config = AppConfig(
      apiBaseUrl: 'https://localhost:7086',
      streamApiKey: '',
      apiMode: ApiMode.live,
    );
    final session = AuthSession(tokenStorage: TokenStorage());

    await tester.pumpWidget(
      await _app(
        config: config,
        session: session,
        initialLocation: '/sign-in',
        child: const OAuthSignInPage(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Continue with LinkedIn'), findsOneWidget);
    expect(
      find.textContaining('https://localhost:7086/auth/linkedin/login'),
      findsNothing,
    );
  });

}
