import 'package:felloway_client/features/trips/domain/trip_chat.dart';
import 'package:felloway_client/features/trips/presentation/trip_request_row.dart';
import 'package:felloway_client/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('TripRequestRow shows low-rating banner when rating low', (
    tester,
  ) async {
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
          body: TripRequestRow(
            request: const TripJoinRequest(
              userId: 'u1',
              displayName: 'Pat',
              homeCityLabel: 'Odesa',
              ratingAverage: 2.5,
            ),
            onApprove: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('trip_low_rating_banner')), findsOneWidget);
    expect(find.byKey(const ValueKey('approve_u1')), findsOneWidget);
  });
}
