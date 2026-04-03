import 'package:felloway_client/app/app_scope.dart';
import 'package:felloway_client/app/auth/auth_session.dart';
import 'package:felloway_client/app/config/app_config.dart';
import 'package:felloway_client/features/auth/data/token_storage.dart';
import 'package:felloway_client/features/chats/application/chat_access_controller.dart';
import 'package:felloway_client/features/chats/data/stream_chat_service.dart';
import 'package:felloway_client/features/events/data/events_repository.dart';
import 'package:felloway_client/features/onboarding/data/onboarding_preferences.dart';
import 'package:felloway_client/features/profile/data/users_repository.dart';
import 'package:felloway_client/features/trips/data/trips_repository.dart';
import 'package:felloway_client/features/trips/presentation/create_trip_page.dart';
import 'package:felloway_client/l10n/app_localizations.dart';
import 'package:felloway_client/shared/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CreateTripPage disables submit until route and city filled', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    const config = AppConfig(
      apiBaseUrl: 'https://test.local',
      streamApiKey: '',
    );
    final tokenStorage = TokenStorage();
    final apiClient = ApiClient(config: config, tokenStorage: tokenStorage);
    final scope = AppScope(
      config: config,
      apiClient: apiClient,
      authSession: AuthSession(tokenStorage: tokenStorage),
      onboardingPreferences: OnboardingPreferences(prefs),
      eventsRepository: EventsRepository(apiClient),
      usersRepository: UsersRepository(apiClient),
      streamChatService: StreamChatService(
        config: config,
        apiClient: apiClient,
      ),
      chatAccessController: ChatAccessController(),
      tripsRepository: TripsRepository(apiClient, config),
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CreateTripPage(eventId: 'e1'),
      ),
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    FilledButton submitButton() => tester.widget<FilledButton>(
      find.byKey(const Key('trip_create_submit')),
    );

    expect(submitButton().onPressed, isNull);

    await tester.enterText(find.byKey(const Key('trip_route_field')), 'A → B');
    await tester.pump();
    expect(submitButton().onPressed, isNull);

    await tester.enterText(find.byKey(const Key('trip_city_field')), 'Kyiv');
    await tester.pump();
    expect(submitButton().onPressed, isNotNull);
  });
}
