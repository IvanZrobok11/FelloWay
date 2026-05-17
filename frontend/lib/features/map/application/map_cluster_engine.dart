import 'dart:math' as math;
import '../domain/map_marker_node.dart';

class MapClusterEngine {
  const MapClusterEngine();

  static const double lowZoomMax = 5.0;
  static const double highZoomMin = 9.0;

  List<MapMarkerNode> cluster({
    required List<MapEventPoint> points,
    required MapViewport viewport,
  }) {
    if (points.isEmpty) return const [];

    final zoom = viewport.zoom;
    if (zoom >= highZoomMin) {
      return points
          .map(
            (p) => MapEventMarkerNode(
              latitude: p.latitude,
              longitude: p.longitude,
              eventId: p.id,
              title: p.title,
            ),
          )
          .toList();
    }

    final radiusKm = zoom <= lowZoomMax ? 90.0 : 35.0;
    final consumed = <int>{};
    final out = <MapMarkerNode>[];

    for (var i = 0; i < points.length; i++) {
      if (consumed.contains(i)) continue;
      final seed = points[i];
      final group = <MapEventPoint>[seed];
      consumed.add(i);
      for (var j = i + 1; j < points.length; j++) {
        if (consumed.contains(j)) continue;
        final candidate = points[j];
        final d = _haversineKm(
          seed.latitude,
          seed.longitude,
          candidate.latitude,
          candidate.longitude,
        );
        if (d <= radiusKm) {
          group.add(candidate);
          consumed.add(j);
        }
      }

      if (group.length == 1) {
        out.add(
          MapEventMarkerNode(
            latitude: seed.latitude,
            longitude: seed.longitude,
            eventId: seed.id,
            title: seed.title,
          ),
        );
      } else {
        final meanLat =
            group.map((e) => e.latitude).reduce((a, b) => a + b) / group.length;
        final meanLng =
            group.map((e) => e.longitude).reduce((a, b) => a + b) /
            group.length;
        out.add(
          MapClusterNode(
            latitude: meanLat,
            longitude: meanLng,
            count: group.length,
            eventIds: group.map((e) => e.id).toList(),
          ),
        );
      }
    }

    return out;
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degToRad(double deg) => deg * (math.pi / 180.0);
}
