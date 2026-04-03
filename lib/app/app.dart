import 'package:flutter/material.dart';
import 'package:felloway_client/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_scope.dart';
import 'auth/auth_session.dart';
import 'config/app_config.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import '../shared/network/api_client.dart';

class FellowayApp extends StatelessWidget {
  const FellowayApp({
    super.key,
    required this.config,
    required this.authSession,
    required this.apiClient,
  });

  final AppConfig config;
  final AuthSession authSession;
  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    final router = createAppRouter(authSession: authSession);
    return AppScope(
      apiClient: apiClient,
      child: MaterialApp.router(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        theme: AppTheme.light(),
        locale: const Locale('uk'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }
}
