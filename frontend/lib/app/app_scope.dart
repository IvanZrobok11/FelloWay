import 'package:flutter/material.dart';

import 'auth/auth_session.dart';
import 'config/app_config.dart';
import '../features/chats/application/chat_access_controller.dart';
import '../features/chats/data/stream_chat_service.dart';
import '../features/events/data/events_repository.dart';
import '../features/onboarding/data/onboarding_draft_store.dart';
import '../features/onboarding/data/onboarding_preferences.dart';
import '../features/profile/data/users_repository.dart';
import '../features/trips/data/trips_repository.dart';
import '../shared/network/api_client.dart';

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.config,
    required this.apiClient,
    required this.authSession,
    required this.onboardingPreferences,
    required this.onboardingDraftStore,
    required this.eventsRepository,
    required this.usersRepository,
    required this.streamChatService,
    required this.chatAccessController,
    required this.tripsRepository,
    required super.child,
  });

  final AppConfig config;
  final ApiClient apiClient;
  final AuthSession authSession;
  final OnboardingPreferences onboardingPreferences;
  final OnboardingDraftStore onboardingDraftStore;
  final EventsRepository eventsRepository;
  final UsersRepository usersRepository;
  final StreamChatService streamChatService;
  final ChatAccessController chatAccessController;
  final TripsRepository tripsRepository;

  static AppScope _of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!;
  }

  static AppConfig configOf(BuildContext context) => _of(context).config;

  static ApiClient apiClientOf(BuildContext context) => _of(context).apiClient;

  static AuthSession authSessionOf(BuildContext context) =>
      _of(context).authSession;

  static OnboardingPreferences onboardingOf(BuildContext context) =>
      _of(context).onboardingPreferences;

  static OnboardingDraftStore onboardingDraftStoreOf(BuildContext context) =>
      _of(context).onboardingDraftStore;

  static EventsRepository eventsOf(BuildContext context) =>
      _of(context).eventsRepository;

  static UsersRepository usersOf(BuildContext context) =>
      _of(context).usersRepository;

  static StreamChatService streamChatOf(BuildContext context) =>
      _of(context).streamChatService;

  static ChatAccessController chatAccessOf(BuildContext context) =>
      _of(context).chatAccessController;

  static TripsRepository tripsOf(BuildContext context) =>
      _of(context).tripsRepository;

  @override
  bool updateShouldNotify(covariant AppScope oldWidget) {
    return oldWidget.config != config ||
        oldWidget.apiClient != apiClient ||
        oldWidget.authSession != authSession ||
        oldWidget.onboardingPreferences != onboardingPreferences ||
        oldWidget.onboardingDraftStore != onboardingDraftStore ||
        oldWidget.eventsRepository != eventsRepository ||
        oldWidget.usersRepository != usersRepository ||
        oldWidget.streamChatService != streamChatService ||
        oldWidget.chatAccessController != chatAccessController ||
        oldWidget.tripsRepository != tripsRepository;
  }
}
