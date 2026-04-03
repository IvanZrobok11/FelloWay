import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/auth/auth_session.dart';
import 'app/config/app_config.dart';
import 'features/auth/data/token_storage.dart';
import 'features/chats/application/chat_access_controller.dart';
import 'features/chats/data/stream_chat_service.dart';
import 'features/events/data/events_repository.dart';
import 'features/onboarding/data/onboarding_preferences.dart';
import 'features/profile/data/users_repository.dart';
import 'features/trips/data/trips_repository.dart';
import 'shared/network/api_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  final tokenStorage = TokenStorage();
  final authSession = AuthSession(tokenStorage: tokenStorage);
  await authSession.restore();
  final prefs = await SharedPreferences.getInstance();
  final onboardingPreferences = OnboardingPreferences(prefs);
  final apiClient = ApiClient(
    config: config,
    tokenStorage: tokenStorage,
    onUnauthorized: authSession.signOut,
  );
  final eventsRepository = EventsRepository(apiClient);
  final usersRepository = UsersRepository(apiClient);
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
      apiClient: apiClient,
      onboardingPreferences: onboardingPreferences,
      eventsRepository: eventsRepository,
      usersRepository: usersRepository,
      tripsRepository: tripsRepository,
      streamChatService: streamChatService,
      chatAccessController: chatAccessController,
    ),
  );
}
