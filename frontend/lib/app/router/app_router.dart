import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_api.dart';
import '../auth/auth_session.dart';
import '../notifications/push_handler.dart';
import '../../features/onboarding/data/onboarding_preferences.dart';
import '../shell/main_shell.dart';
import '../../features/auth/presentation/oauth_sign_in_page.dart';
import '../../features/chats/presentation/channel_page.dart';
import '../../features/chats/presentation/chats_list_page.dart';
import '../../features/events/presentation/event_detail_page.dart';
import '../../features/events/presentation/events_list_page.dart';
import '../../features/map/presentation/map_page.dart';
import '../../features/onboarding/presentation/city_page.dart';
import '../../features/onboarding/presentation/interests_page.dart';
import '../../features/onboarding/presentation/name_page.dart';
import '../../features/onboarding/presentation/welcome_page.dart';
import '../../features/profile/presentation/event_feedback_page.dart';
import '../../features/profile/presentation/notification_settings_page.dart';
import '../../features/profile/presentation/profile_edit_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/profile/presentation/reviews_list.dart';
import '../../features/trips/presentation/create_trip_page.dart';
import '../../features/trips/presentation/trip_owner_requests_page.dart';

GoRouter createAppRouter({
  required AuthSession authSession,
  required OnboardingPreferences onboardingPreferences,
  AuthApi? webSessionAuthApi,
  bool syncWebCookieSession = false,
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  return GoRouter(
    navigatorKey: navigatorKey ?? PushHandler.rootNavigatorKey,
    initialLocation: onboardingPreferences.isComplete
        ? '/events'
        : '/onboarding/welcome',
    refreshListenable: authSession,
    redirect: (context, state) async {
      final path = state.uri.path;
      final onOnboarding = path.startsWith('/onboarding');
      final onSignIn = path == '/sign-in';
      final onAuthSuccess = path == '/auth/success';

      if (!authSession.isAuthenticated &&
          syncWebCookieSession &&
          webSessionAuthApi != null) {
        await authSession.syncWebCookieSession(webSessionAuthApi);
      }

      if (!authSession.isAuthenticated) {
        if (onAuthSuccess) {
          return null;
        }
        if (onSignIn || onOnboarding) {
          return null;
        }
        final protected =
            path == '/events' ||
            path == '/map' ||
            path == '/chats' ||
            path == '/profile' ||
            path.startsWith('/event/') ||
            path.startsWith('/trips/') ||
            path.startsWith('/chats/');
        if (protected) {
          return '/sign-in?reason=session_expired';
        }
        return null;
      }

      if (authSession.isAuthenticated &&
          onboardingPreferences.isComplete &&
          onOnboarding) {
        return '/events';
      }

      if (authSession.isAuthenticated && !onboardingPreferences.isComplete) {
        if (!onOnboarding && !onSignIn) {
          return '/onboarding/welcome';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const OAuthSignInPage(),
      ),
      GoRoute(
        path: '/auth/success',
        builder: (context, state) => const OAuthBffSuccessPage(),
      ),
      GoRoute(
        path: '/onboarding/welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/onboarding/name',
        builder: (context, state) => const NamePage(),
      ),
      GoRoute(
        path: '/onboarding/interests',
        builder: (context, state) => const InterestsPage(),
      ),
      GoRoute(
        path: '/onboarding/city',
        builder: (context, state) => const CityPage(),
      ),
      GoRoute(
        path: '/event/:eventId',
        builder: (context, state) =>
            EventDetailPage(eventId: state.pathParameters['eventId']!),
      ),
      GoRoute(
        path: '/event/:eventId/trips/create',
        builder: (context, state) {
          final city = state.uri.queryParameters['city'] ?? '';
          return CreateTripPage(
            eventId: state.pathParameters['eventId']!,
            suggestedCity: city.isEmpty ? '' : Uri.decodeComponent(city),
          );
        },
      ),
      GoRoute(
        path: '/trips/:tripId/requests',
        builder: (context, state) {
          final eid = state.uri.queryParameters['eventId'] ?? '';
          return TripOwnerRequestsPage(
            tripId: state.pathParameters['tripId']!,
            eventId: eid.isEmpty ? '' : Uri.decodeComponent(eid),
          );
        },
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const ProfileEditPage(),
      ),
      GoRoute(
        path: '/profile/notifications',
        builder: (context, state) => const NotificationSettingsPage(),
      ),
      GoRoute(
        path: '/profile/reviews',
        builder: (context, state) => const ProfileReviewsPage(),
      ),
      GoRoute(
        path: '/event/:eventId/feedback',
        builder: (context, state) =>
            EventFeedbackPage(eventId: state.pathParameters['eventId']!),
      ),
      GoRoute(
        path: '/chats/channel',
        builder: (context, state) {
          final type = state.uri.queryParameters['type'] ?? 'messaging';
          final id = state.uri.queryParameters['id'] ?? '';
          if (id.isEmpty) {
            return const Scaffold(body: Center(child: Text('Invalid channel')));
          }
          return ChannelPage(
            channelType: type,
            channelId: Uri.decodeComponent(id),
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/events',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: EventsListPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                name: 'map',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: MapPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chats',
                name: 'chats',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ChatsListPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ProfilePage()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
