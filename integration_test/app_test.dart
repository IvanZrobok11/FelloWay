import 'package:felloway_client/app/app.dart';
import 'package:felloway_client/app/auth/auth_session.dart';
import 'package:felloway_client/app/config/app_config.dart';
import 'package:felloway_client/features/auth/data/token_storage.dart';
import 'package:felloway_client/shared/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app shows main navigation shell', (tester) async {
    WidgetsFlutterBinding.ensureInitialized();
    final config = AppConfig.fromEnvironment();
    final tokenStorage = TokenStorage();
    final authSession = AuthSession(tokenStorage: tokenStorage);
    await authSession.restore();
    final apiClient = ApiClient(
      config: config,
      tokenStorage: tokenStorage,
      onUnauthorized: authSession.signOut,
    );

    await tester.pumpWidget(
      FellowayApp(
        config: config,
        authSession: authSession,
        apiClient: apiClient,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
