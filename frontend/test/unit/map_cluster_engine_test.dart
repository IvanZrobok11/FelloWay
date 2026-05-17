import 'package:felloway_client/features/map/application/map_cluster_engine.dart';
import 'package:felloway_client/features/map/domain/map_marker_node.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = MapClusterEngine();
  final points = List.generate(
    24,
    (i) => MapEventPoint(
      id: 'e$i',
      title: 'Event $i',
      latitude: 50.4 + (i % 4) * 0.001,
      longitude: 30.5 + (i ~/ 4) * 0.001,
    ),
  );

  test('low zoom clusters into fewer nodes', () {
    final out = engine.cluster(
      points: points,
      viewport: const MapViewport(zoom: 4),
    );
    expect(out.length, lessThan(points.length));
    expect(out.any((e) => e is MapClusterNode), isTrue);
  });

  test('medium zoom still clusters but with more detail', () {
    final low = engine.cluster(
      points: points,
      viewport: const MapViewport(zoom: 4),
    );
    final mid = engine.cluster(
      points: points,
      viewport: const MapViewport(zoom: 7),
    );
    expect(mid.length, greaterThanOrEqualTo(low.length));
  });

  test('high zoom disables clustering to individual markers', () {
    final out = engine.cluster(
      points: points,
      viewport: const MapViewport(zoom: 11),
    );
    expect(out.length, points.length);
    expect(out.every((e) => e is MapEventMarkerNode), isTrue);
  });
}
