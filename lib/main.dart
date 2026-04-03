import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/auth/auth_session.dart';
import 'app/config/app_config.dart';
import 'features/auth/data/token_storage.dart';
import 'shared/network/api_client.dart';

Future<void> main() async {
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
  runApp(
    FellowayApp(config: config, authSession: authSession, apiClient: apiClient),
  );
}
