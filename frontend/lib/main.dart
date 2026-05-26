import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/configure_url_strategy.dart';
import 'app/app.dart';
import 'app/auth/auth_session.dart';
import 'app/config/app_config_loader.dart';
import 'features/auth/data/auth_api.dart';
import 'features/auth/data/token_storage.dart';
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
  final tokenStorage = TokenStorage();
  final authSession = AuthSession(tokenStorage: tokenStorage);
  await authSession.restore();
  final prefs = await SharedPreferences.getInstance();
  final onboardingPreferences = OnboardingPreferences(prefs);
  final onboardingDraftStore = OnboardingDraftStore(prefs);
  final useWebCookies = kIsWeb && !config.useMockApi;
  final authApi = AuthApi(
    baseUrl: config.apiBaseUrl,
    sendCredentials: useWebCookies,
  );
  final apiClient = ApiClient(
    config: config,
    tokenStorage: tokenStorage,
    authApi: authApi,
    onUnauthorized: authSession.signOut,
    useCookieAuthOnWeb: useWebCookies,
  );
  if (useWebCookies) {
    final bffTicket = bffTicketFromBrowser();
    final crossOriginBff = kIsWeb && isCrossOriginApi(config.apiBaseUrl);
    if (bffTicket != null && bffTicket.isNotEmpty) {
      try {
        final tokens = await authApi.completeLinkedInMobile(ticket: bffTicket);
        if (tokens.accessToken.isNotEmpty) {
          await authSession.setAuthenticated(
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken,
          );
        }
      } on Object {
        // OAuthBffSuccessPage retries with the same ticket from the browser URL.
      }
    } else if (!crossOriginBff) {
      await authSession.syncWebCookieSession(authApi);
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
