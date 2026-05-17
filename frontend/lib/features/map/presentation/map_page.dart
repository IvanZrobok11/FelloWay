import 'package:flutter/material.dart';
import 'package:felloway_client/l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/app_scope.dart';
import '../../../shared/errors/result.dart';
import '../../events/domain/event.dart';
import '../application/map_camera_controller.dart';
import '../application/map_cluster_engine.dart';
import '../domain/map_marker_node.dart';
import 'widgets/map_cluster_marker.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const _tags = ['IT', 'Marketing', 'HR', 'Design'];

  final _mapController = MapController();
  final _camera = MapCameraController();
  final _engine = const MapClusterEngine();
  List<EventSummary> _events = [];
  bool _loading = true;
  String? _interestFilter;

  @override
  void initState() {
    super.initState();
    _camera.addListener(_onCameraChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _camera
      ..removeListener(_onCameraChanged)
      ..dispose();
    super.dispose();
  }

  void _onCameraChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final repo = AppScope.eventsOf(context);
    final res = await repo.listEvents(interest: _interestFilter);
    if (!mounted) return;
    switch (res) {
      case Success(:final value):
        setState(() {
          _events = value.items;
          _loading = false;
        });
      case Failure():
        setState(() => _loading = false);
    }
  }

  List<MapEventPoint> _toPoints(List<EventSummary> list) {
    return list
        .where((e) => e.latitude != null && e.longitude != null)
        .map(
          (e) => MapEventPoint(
            id: e.id,
            title: e.title,
            latitude: e.latitude!,
            longitude: e.longitude!,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.mapScreenTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              l10n.mapDiscoveryHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: Text(l10n.mapFilterAll),
                  selected: _interestFilter == null,
                  onSelected: (_) {
                    setState(() => _interestFilter = null);
                    _load();
                  },
                ),
                const SizedBox(width: 8),
                ..._tags.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(t),
                      selected: _interestFilter == t,
                      onSelected: (v) {
                        setState(() => _interestFilter = v ? t : null);
                        _load();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _buildMap(context, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(BuildContext context, AppLocalizations l10n) {
    final points = _toPoints(_events);
    final nodes = _engine.cluster(
      points: points,
      viewport: MapViewport(zoom: _camera.zoom),
    );

    if (points.isEmpty) {
      return Center(child: Text(l10n.emptyStateTitle));
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(_camera.centerLatitude, _camera.centerLongitude),
        initialZoom: _camera.zoom,
        minZoom: _camera.minZoom,
        maxZoom: _camera.maxZoom,
        onPositionChanged: (position, _) {
          final center = position.center;
          final zoom = position.zoom;
          _camera.setView(
            latitude: center.latitude,
            longitude: center.longitude,
            zoomLevel: zoom,
          );
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.felloway.client',
        ),
        MarkerLayer(
          markers: [
            for (final n in nodes)
              Marker(
                point: LatLng(n.latitude, n.longitude),
                width: n is MapClusterNode ? 88 : 150,
                height: n is MapClusterNode ? 44 : 36,
                child: n is MapClusterNode
                    ? MapClusterMarker(
                        label: l10n.mapClusterEventsCount(n.count),
                        isCluster: true,
                        scale: 1,
                        onTap: () {
                          _mapController.move(
                            LatLng(n.latitude, n.longitude),
                            (_camera.zoom + 1).clamp(
                              _camera.minZoom,
                              _camera.maxZoom,
                            ),
                          );
                        },
                      )
                    : MapClusterMarker(
                        label: (n as MapEventMarkerNode).title,
                        isCluster: false,
                        scale: 1,
                        onTap: () => context.push('/event/${n.eventId}'),
                      ),
              ),
          ],
        ),
      ],
    );
  }
}
