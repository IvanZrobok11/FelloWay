import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:felloway_client/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../features/auth/data/auth_api.dart';
import '../features/chats/application/chat_access_controller.dart';
import '../features/chats/data/stream_chat_service.dart';
import '../features/events/data/events_repository.dart';
import '../features/onboarding/data/interests_repository.dart';
import '../features/onboarding/data/onboarding_draft_store.dart';
import '../features/onboarding/data/onboarding_preferences.dart';
import '../features/profile/data/users_repository.dart';
import '../features/trips/data/trips_repository.dart';
import '../shared/network/api_client.dart';
import '../shared/widgets/connectivity_snack_bar.dart';
import 'app_scope.dart';
import 'auth/auth_session.dart';
import 'config/app_config.dart';
import 'notifications/push_handler.dart';
import 'router/app_router.dart';
import '../shared/widgets/app_background.dart';
import 'theme/app_theme.dart';

class FellowayApp extends StatefulWidget {
  const FellowayApp({
    super.key,
    required this.config,
    required this.authSession,
    required this.authApi,
    required this.apiClient,
    required this.onboardingPreferences,
    required this.onboardingDraftStore,
    required this.interestsRepository,
    required this.eventsRepository,
    required this.usersRepository,
    required this.streamChatService,
    required this.chatAccessController,
    required this.tripsRepository,
  });

  final AppConfig config;
  final AuthSession authSession;
  final AuthApi authApi;
  final ApiClient apiClient;
  final OnboardingPreferences onboardingPreferences;
  final OnboardingDraftStore onboardingDraftStore;
  final InterestsRepository interestsRepository;
  final EventsRepository eventsRepository;
  final UsersRepository usersRepository;
  final StreamChatService streamChatService;
  final ChatAccessController chatAccessController;
  final TripsRepository tripsRepository;

  @override
  State<FellowayApp> createState() => _FellowayAppState();
}

class _FellowayAppState extends State<FellowayApp> {
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    widget.authSession.addListener(_onAuthChanged);
    widget.authSession.addListener(_onConnectivityNotice);
    widget.streamChatService.addListener(_onStreamChanged);
    _router = createAppRouter(
      authSession: widget.authSession,
      onboardingPreferences: widget.onboardingPreferences,
      webSessionAuthApi: widget.authApi,
      syncWebCookieSession: kIsWeb && !widget.config.useMockApi,
      navigatorKey: PushHandler.rootNavigatorKey,
    );
    PushHandler.attach(_router!);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await PushHandler.registerMessagingBridge();
      await _syncChat();
      _showConnectivityNoticeIfNeeded();
    });
  }

  void _onConnectivityNotice() {
    _showConnectivityNoticeIfNeeded();
  }

  void _showConnectivityNoticeIfNeeded() {
    if (!widget.authSession.consumeConnectivityNotice()) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ConnectivitySnackBar.showGlobal();
    });
  }

  @override
  void dispose() {
    widget.authSession.removeListener(_onAuthChanged);
    widget.authSession.removeListener(_onConnectivityNotice);
    widget.streamChatService.removeListener(_onStreamChanged);
    PushHandler.detach();
    _router?.dispose();
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
    final router = _router!;
    Widget child = AppScope(
      config: widget.config,
      apiClient: widget.apiClient,
      authApi: widget.authApi,
      authSession: widget.authSession,
      onboardingPreferences: widget.onboardingPreferences,
      onboardingDraftStore: widget.onboardingDraftStore,
      interestsRepository: widget.interestsRepository,
      eventsRepository: widget.eventsRepository,
      usersRepository: widget.usersRepository,
      streamChatService: widget.streamChatService,
      chatAccessController: widget.chatAccessController,
      tripsRepository: widget.tripsRepository,
      child: MaterialApp.router(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        theme: AppTheme.light(),
        builder: (context, child) {
          // Do not use router.state here — it can be empty on first frame (No element).
          return ListenableBuilder(
            listenable: router.routeInformationProvider,
            builder: (context, _) {
              final path = router.routeInformationProvider.value.uri.path;
              return AppBackground(
                intro: path.startsWith('/onboarding'),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
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
