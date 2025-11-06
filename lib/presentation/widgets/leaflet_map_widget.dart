import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LeafletMapWidget extends StatelessWidget {
  const LeafletMapWidget({
    super.key,
    required this.center,
    this.markers = const [],
    this.zoom = 15.0,
  });
  final LatLng center;
  final List<Marker> markers;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        maxZoom: 18,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.campus_wa',
          errorImage: const NetworkImage(
            'https://tile.openstreetmap.org/0/0/0.png',
          ),
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}
