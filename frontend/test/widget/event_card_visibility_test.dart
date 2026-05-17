import 'package:felloway_client/features/events/domain/event.dart';
import 'package:felloway_client/features/events/presentation/event_card.dart';
import 'package:felloway_client/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

EventSummary _sample() {
  return EventSummary(
    id: '1',
    title: 'Conf',
    startsAt: DateTime(2026, 5, 1),
    endsAt: DateTime(2026, 5, 2),
    city: 'Kyiv',
    venueName: 'Venue',
    imageUrls: const [],
    tags: const ['IT'],
    attendeePreview: const [
      EventAttendeePreview(id: 'a', displayName: 'Sam', city: 'Kyiv'),
    ],
  );
}

void main() {
  testWidgets('guest card hides attendee preview names', (tester) async {
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
        home: Scaffold(
          body: SingleChildScrollView(
            child: EventCard(summary: _sample(), isGuest: true, onTap: () {}),
          ),
        ),
      ),
    );
    expect(find.textContaining('Sam'), findsNothing);
  });

  testWidgets('signed-in card shows attendee preview', (tester) async {
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
        home: Scaffold(
          body: SingleChildScrollView(
            child: EventCard(summary: _sample(), isGuest: false, onTap: () {}),
          ),
        ),
      ),
    );
    expect(find.textContaining('Sam'), findsOneWidget);
  });
}
