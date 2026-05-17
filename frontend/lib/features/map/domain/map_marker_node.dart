class MapViewport {
  const MapViewport({required this.zoom});

  final double zoom;
}

class MapEventPoint {
  const MapEventPoint({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String title;
  final double latitude;
  final double longitude;
}

sealed class MapMarkerNode {
  const MapMarkerNode({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

class MapEventMarkerNode extends MapMarkerNode {
  const MapEventMarkerNode({
    required super.latitude,
    required super.longitude,
    required this.eventId,
    required this.title,
  });

  final String eventId;
  final String title;
}

class MapClusterNode extends MapMarkerNode {
  const MapClusterNode({
    required super.latitude,
    required super.longitude,
    required this.count,
    required this.eventIds,
  });

  final int count;
  final List<String> eventIds;
}
