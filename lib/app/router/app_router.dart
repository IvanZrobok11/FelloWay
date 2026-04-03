import 'package:go_router/go_router.dart';

import '../auth/auth_session.dart';
import '../../features/onboarding/data/onboarding_preferences.dart';
import '../shell/main_shell.dart';
import '../../features/auth/presentation/oauth_sign_in_page.dart';
import '../../features/chats/presentation/chats_list_page.dart';
import '../../features/events/presentation/event_detail_page.dart';
import '../../features/events/presentation/events_list_page.dart';
import '../../features/map/presentation/map_page.dart';
import '../../features/onboarding/presentation/city_page.dart';
import '../../features/onboarding/presentation/interests_page.dart';
import '../../features/onboarding/presentation/name_page.dart';
import '../../features/onboarding/presentation/welcome_page.dart';
import '../../features/profile/presentation/profile_page.dart';

GoRouter createAppRouter({
  required AuthSession authSession,
  required OnboardingPreferences onboardingPreferences,
}) {
  return GoRouter(
    initialLocation: '/events',
    refreshListenable: authSession,
    redirect: (context, state) {
      final path = state.uri.path;
      final onOnboarding = path.startsWith('/onboarding');
      final onSignIn = path == '/sign-in';

      if (!authSession.isAuthenticated) {
        if (onOnboarding) return '/events';
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
