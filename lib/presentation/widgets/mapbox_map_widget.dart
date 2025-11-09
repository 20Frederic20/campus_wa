import 'package:campus_wa/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapboxMapWidget extends StatefulWidget {
  const MapboxMapWidget({
    super.key,
    required this.center,
    this.markers,
    this.zoom = 15.0,
  });
  final LatLng center;
  final List<LatLng>? markers;
  final double zoom;

  @override
  State<MapboxMapWidget> createState() => _MapboxMapWidgetState();
}

class _MapboxMapWidgetState extends State<MapboxMapWidget> {
  MapboxMap? _mapboxMap;
  CircleAnnotationManager? _circleAnnotationManager;
  final List<CircleAnnotation> _circleAnnotations = [];

  @override
  void initState() {
    super.initState();
    final token = dotenv.env["MAPBOX_ACCESS_TOKEN"];
    if (token != null && token.isNotEmpty) {
      MapboxOptions.setAccessToken(token);
    } else {
      // avoid null-check operator; log a warning so the app doesn't crash
      // You can also show a user-facing message or provide a fallback here
      // ignore: avoid_print
      print('Warning: MAPBOX_ACCESS_TOKEN is not set.');
    }
  }

  @override
  void dispose() {
    _circleAnnotationManager?.deleteAll(); // Remove all annotations on dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MapboxMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_mapboxMap != null &&
        (_circleAnnotationManager != null) &&
        (oldWidget.markers != widget.markers ||
            oldWidget.center != widget.center)) {
      _updateMarkers();
    }
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    await mapboxMap.setCamera(
      CameraOptions(
        center: Point(
          coordinates: Position(
            widget.center.longitude,
            widget.center.latitude,
          ),
        ),
        zoom: widget.zoom,
      ),
    );

    // Create the circle annotation manager
    _circleAnnotationManager = await _mapboxMap!.annotations
        .createCircleAnnotationManager();

    await _updateMarkers();
  }

  Future<void> _updateMarkers() async {
    if (_circleAnnotationManager == null) return;

    // remove existing annotations
    try {
      if (_circleAnnotations.isNotEmpty) {
        // deleteAll if available
        try {
          await _circleAnnotationManager!.deleteAll();
        } catch (_) {
          // fallback: delete individually
          for (final ann in List<CircleAnnotation>.from(_circleAnnotations)) {
            try {
              await _circleAnnotationManager!.delete(ann);
            } catch (_) {}
          }
        }
      }
    } catch (_) {}

    _circleAnnotations.clear();

    final center = widget.center;
    if (center != null) {
      final centerOptions = CircleAnnotationOptions(
        geometry: Point(
          coordinates: Position(center.longitude, center.latitude),
        ),
        circleColor: AppColors.primaryBlue.value, // blue for user
        circleRadius: 10.0,
        circleStrokeColor: AppColors.white.value,
        circleStrokeWidth: 1.5,
      );
      try {
        final centerAnn = await _circleAnnotationManager!.create(centerOptions);
        _circleAnnotations.add(centerAnn);
      } catch (e) {
        // ignore but log
        // ignore: avoid_print
        print('Center marker creation error: $e');
      }
    }
    final markers = widget.markers ?? [];
    for (final m in markers) {
      final options = CircleAnnotationOptions(
        geometry: Point(coordinates: Position(m.longitude, m.latitude)),
        circleColor: AppColors.accentRed.value, // red fill
        circleRadius: 8.0,
        circleStrokeWidth: 1.5,
        circleStrokeColor: AppColors.primaryGreen.value,
      );

      try {
        final ann = await _circleAnnotationManager!.create(options);
        _circleAnnotations.add(ann);
      } catch (e) {
        // ignore annotation creation errors but keep app stable
        // ignore: avoid_print
        print('Marker creation error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapWidget(
        key: const ValueKey("mapWidget"),
        styleUri: MapboxStyles.MAPBOX_STREETS,
        onMapCreated: _onMapCreated, // Now calls the async method
      ),
    );
  }
}
