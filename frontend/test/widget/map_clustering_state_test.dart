import 'package:felloway_client/features/map/presentation/widgets/map_cluster_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('cluster marker renders count label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MapClusterMarker(label: '24 events', isCluster: true, scale: 1),
        ),
      ),
    );

    expect(find.text('24 events'), findsOneWidget);
  });

  testWidgets('event marker renders event title', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MapClusterMarker(
            label: 'Flutter Summit',
            isCluster: false,
            scale: 1,
          ),
        ),
      ),
    );

    expect(find.text('Flutter Summit'), findsOneWidget);
  });
}
