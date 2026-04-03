import 'package:felloway_client/app/app.dart';
import 'package:felloway_client/app/auth/auth_session.dart';
import 'package:felloway_client/app/config/app_config.dart';
import 'package:felloway_client/features/auth/data/token_storage.dart';
import 'package:felloway_client/features/events/data/events_repository.dart';
import 'package:felloway_client/features/onboarding/data/onboarding_preferences.dart';
import 'package:felloway_client/features/profile/data/users_repository.dart';
import 'package:felloway_client/shared/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async {
          switch (call.method) {
            case 'read':
              return null;
            default:
              return null;
          }
        });
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  testWidgets('guest can open event and sees join sign-in prompt', (
    tester,
  ) async {
    WidgetsFlutterBinding.ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    final onboarding = OnboardingPreferences(prefs);
    const config = AppConfig(
      apiBaseUrl: 'https://api.example.com',
      streamApiKey: '',
    );
    final tokenStorage = TokenStorage();
    final authSession = AuthSession(tokenStorage: tokenStorage);
    await authSession.restore();
    final apiClient = ApiClient(config: config, tokenStorage: tokenStorage);
    final eventsRepository = EventsRepository(apiClient);
    final usersRepository = UsersRepository(apiClient);

    await tester.pumpWidget(
      FellowayApp(
        config: config,
        authSession: authSession,
        apiClient: apiClient,
        onboardingPreferences: onboarding,
        eventsRepository: eventsRepository,
        usersRepository: usersRepository,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Flutter').first);
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('приєднатися').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('Увійдіть'), findsWidgets);
  });
}
