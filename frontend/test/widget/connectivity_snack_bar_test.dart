import 'package:felloway_client/l10n/app_localizations.dart';
import 'package:felloway_client/shared/widgets/connectivity_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildHarness({required VoidCallback onShow}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: Center(
          child: ElevatedButton(onPressed: onShow, child: const Text('Show')),
        ),
      ),
    );
  }

  testWidgets('shows wifi icon, message, and floating snack bar', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(
        onShow: () =>
            ConnectivitySnackBar.show(tester.element(find.byType(Scaffold))),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();

    expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    expect(
      find.text('Action unavailable. No internet connection.'),
      findsOneWidget,
    );
    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.behavior, SnackBarBehavior.floating);
    expect(snackBar.backgroundColor, const Color(0xFF212121));
    expect(snackBar.duration, const Duration(seconds: 4));
  });

  testWidgets('close action dismisses snack bar', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildHarness(onShow: () {}));
    final context = tester.element(find.byType(Scaffold));
    ConnectivitySnackBar.show(context);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('second show clears previous snack bar', (tester) async {
    await tester.pumpWidget(buildHarness(onShow: () {}));
    final context = tester.element(find.byType(Scaffold));
    ConnectivitySnackBar.show(context);
    await tester.pump();
    ConnectivitySnackBar.show(context);
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
  });
}
