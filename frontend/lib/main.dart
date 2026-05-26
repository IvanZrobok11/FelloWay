import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/configure_url_strategy.dart';
import 'app/app.dart';
import 'app/auth/auth_session.dart';
import 'app/config/app_config_loader.dart';
import 'features/auth/application/auth_completion_service.dart';
import 'features/auth/data/auth_api.dart';
import 'features/auth/data/token_storage.dart';
import 'features/auth/domain/web_auth_mode.dart';
import 'features/auth/web/bff_ticket_from_browser.dart';
import 'features/chats/application/chat_access_controller.dart';
import 'features/chats/data/stream_chat_service.dart';
import 'features/events/data/events_repository.dart';
import 'features/onboarding/data/interests_repository.dart';
import 'features/onboarding/data/onboarding_draft_store.dart';
import 'features/onboarding/data/onboarding_preferences.dart';
import 'features/profile/data/users_repository.dart';
import 'features/trips/data/trips_repository.dart';
import 'shared/network/api_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureWebUrlStrategy();
  final config = await loadAppConfig();
  final prefs = await SharedPreferences.getInstance();
  final tokenStorage = TokenStorage(webPreferences: prefs);
  final authSession = AuthSession(tokenStorage: tokenStorage);
  await authSession.restore();
  final onboardingPreferences = OnboardingPreferences(prefs);
  final onboardingDraftStore = OnboardingDraftStore(prefs);

  final webAuthMode = kIsWeb ? resolveWebAuthMode(config.apiBaseUrl) : null;
  final useWebCookies = useWebCookieAuth(
    isWeb: kIsWeb,
    useMockApi: config.useMockApi,
    webAuthMode: webAuthMode ?? WebAuthMode.sameOriginCookie,
  );

  final authApi = AuthApi(
    baseUrl: config.apiBaseUrl,
    sendCredentials: useWebCookies,
  );
  final authCompletion = AuthCompletionService(
    authApi: authApi,
    authSession: authSession,
    webAuthMode: webAuthMode ?? WebAuthMode.sameOriginCookie,
  );

  final apiClient = ApiClient(
    config: config,
    tokenStorage: tokenStorage,
    authApi: authApi,
    onUnauthorized: authSession.signOut,
    useCookieAuthOnWeb: useWebCookies,
  );

  if (kIsWeb && !config.useMockApi) {
    final bffTicket = readBffTicket();
    if (bffTicket != null && bffTicket.isNotEmpty) {
      final result = await authCompletion.completeFromTicket(bffTicket);
      if (result == AuthCompletionResult.failed && kDebugMode) {
        debugPrint(
          'BFF ticket handoff failed on startup (check Network for '
          'POST /auth/linkedin/mobile/complete and CORS)',
        );
      }
    } else if (authCompletion.shouldProbeCookieSession) {
      await authCompletion.probeCookieSession();
    }
  }

  final eventsRepository = EventsRepository(apiClient, config);
  final interestsRepository = InterestsRepository(apiClient);
  final usersRepository = UsersRepository(apiClient, config);
  final tripsRepository = TripsRepository(apiClient, config);
  final streamChatService = StreamChatService(
    config: config,
    apiClient: apiClient,
  );
  final chatAccessController = ChatAccessController();
  runApp(
    FellowayApp(
      config: config,
      authSession: authSession,
      authApi: authApi,
      authCompletion: authCompletion,
      apiClient: apiClient,
      onboardingPreferences: onboardingPreferences,
      onboardingDraftStore: onboardingDraftStore,
      interestsRepository: interestsRepository,
      eventsRepository: eventsRepository,
      usersRepository: usersRepository,
      tripsRepository: tripsRepository,
      streamChatService: streamChatService,
      chatAccessController: chatAccessController,
    ),
  );
}
