import 'package:felloway_client/features/events/domain/event.dart';
import 'package:felloway_client/features/onboarding/presentation/welcome_page.dart';
import 'package:felloway_client/features/events/presentation/event_card.dart';
import 'package:felloway_client/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EventCard matches golden', (tester) async {
    final summary = EventSummary(
      id: '1',
      title: 'Golden IT Meetup',
      startsAt: DateTime.utc(2026, 6, 15, 10, 0),
      endsAt: DateTime.utc(2026, 6, 15, 18, 0),
      city: 'Kyiv',
      venueName: 'Expo',
      imageUrls: const [],
      tags: const ['Flutter', 'Dart'],
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData.light(),
        home: Scaffold(
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: EventCard(summary: summary, isGuest: false, onTap: () {}),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(EventCard),
      matchesGoldenFile('goldens/event_card.png'),
    );
  });

  testWidgets('Welcome onboarding chrome matches golden', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const WelcomePage()),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData.light(),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(WelcomePage),
      matchesGoldenFile('goldens/onboarding_welcome.png'),
    );
  });
}
