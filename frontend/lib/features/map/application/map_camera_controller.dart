import 'dart:async';
import 'package:flutter/foundation.dart';

class MapCameraController extends ChangeNotifier {
  MapCameraController({
    this.zoom = 6.0,
    this.centerLatitude = 50.4501,
    this.centerLongitude = 30.5234,
    this.minZoom = 2.5,
    this.maxZoom = 12.0,
    this.debounce = const Duration(milliseconds: 80),
  });

  final double minZoom;
  final double maxZoom;
  final Duration debounce;

  double zoom;
  double centerLatitude;
  double centerLongitude;

  Timer? _timer;

  void setView({
    required double latitude,
    required double longitude,
    required double zoomLevel,
  }) {
    centerLatitude = latitude;
    centerLongitude = longitude;
    zoom = zoomLevel.clamp(minZoom, maxZoom);
    _schedule();
  }

  void reset() {
    centerLatitude = 50.4501;
    centerLongitude = 30.5234;
    zoom = 6.0;
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer(debounce, notifyListeners);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
