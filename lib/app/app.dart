import 'package:flutter/material.dart';
import 'package:felloway_client/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../features/chats/application/chat_access_controller.dart';
import '../features/chats/data/stream_chat_service.dart';
import '../features/events/data/events_repository.dart';
import '../features/onboarding/data/onboarding_preferences.dart';
import '../features/profile/data/users_repository.dart';
import '../shared/network/api_client.dart';
import 'app_scope.dart';
import 'auth/auth_session.dart';
import 'config/app_config.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class FellowayApp extends StatefulWidget {
  const FellowayApp({
    super.key,
    required this.config,
    required this.authSession,
    required this.apiClient,
    required this.onboardingPreferences,
    required this.eventsRepository,
    required this.usersRepository,
    required this.streamChatService,
    required this.chatAccessController,
  });

  final AppConfig config;
  final AuthSession authSession;
  final ApiClient apiClient;
  final OnboardingPreferences onboardingPreferences;
  final EventsRepository eventsRepository;
  final UsersRepository usersRepository;
  final StreamChatService streamChatService;
  final ChatAccessController chatAccessController;

  @override
  State<FellowayApp> createState() => _FellowayAppState();
}

class _FellowayAppState extends State<FellowayApp> {
  @override
  void initState() {
    super.initState();
    widget.authSession.addListener(_onAuthChanged);
    widget.streamChatService.addListener(_onStreamChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncChat());
  }

  @override
  void dispose() {
    widget.authSession.removeListener(_onAuthChanged);
    widget.streamChatService.removeListener(_onStreamChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (!widget.authSession.isAuthenticated) {
      widget.chatAccessController.clear();
    }
    _syncChat();
  }

  void _onStreamChanged() {
    setState(() {});
  }

  Future<void> _syncChat() async {
    await widget.streamChatService.syncWithSession(
      isAuthenticated: widget.authSession.isAuthenticated,
      usersRepository: widget.usersRepository,
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final router = createAppRouter(
      authSession: widget.authSession,
      onboardingPreferences: widget.onboardingPreferences,
    );
    Widget child = AppScope(
      config: widget.config,
      apiClient: widget.apiClient,
      authSession: widget.authSession,
      onboardingPreferences: widget.onboardingPreferences,
      eventsRepository: widget.eventsRepository,
      usersRepository: widget.usersRepository,
      streamChatService: widget.streamChatService,
      chatAccessController: widget.chatAccessController,
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

    final client = widget.streamChatService.client;
    if (client != null) {
      child = StreamChat(client: client, child: child);
    }

    return child;
  }
}
