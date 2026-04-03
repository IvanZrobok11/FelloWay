import 'package:go_router/go_router.dart';

import '../auth/auth_session.dart';
import '../shell/main_shell.dart';
import '../../features/chats/presentation/chats_list_page.dart';
import '../../features/events/presentation/events_list_page.dart';
import '../../features/map/presentation/map_page.dart';
import '../../features/profile/presentation/profile_page.dart';

GoRouter createAppRouter({required AuthSession authSession}) {
  return GoRouter(
    initialLocation: '/events',
    refreshListenable: authSession,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/events',
                name: 'events',
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
