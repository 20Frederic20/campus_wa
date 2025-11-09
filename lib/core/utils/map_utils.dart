import 'dart:math';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openGoogleMaps({
  required BuildContext context,
  required LatLng position,
  String? address,
}) async {
  try {
    final coords = position;
    final query = address ?? '${coords.latitude},${coords.longitude}';
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );

    final canLaunch = await canLaunchUrl(url);
    if (canLaunch) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;
      await launchUrl(url, mode: LaunchMode.externalNonBrowserApplication);
    }
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Erreur lors de l\'ouverture de Google Maps: ${e.toString()}',
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}

double _degreesToRadians(double degrees) => degrees * (pi / 180.0);

double haversineDistanceKm(double lat1, double lon1, double lat2, double lon2) {
  const earthRadiusKm = 6371.0;
  final dLat = _degreesToRadians(lat2 - lat1);
  final dLon = _degreesToRadians(lon2 - lon1);
  final a =
      (sin(dLat / 2) * sin(dLat / 2)) +
      (cos(_degreesToRadians(lat1)) *
          cos(_degreesToRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2));
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadiusKm * c;
}

List<T> filterWithinKm<T>(
  List<T> items,
  double centerLat,
  double centerLon,
  double maxKm,
  double Function(T) latitude,
  double Function(T) longitude,
) {
  return items.where((it) {
    final d = haversineDistanceKm(
      centerLat,
      centerLon,
      latitude(it),
      longitude(it),
    );
    return d <= maxKm;
  }).toList();
}
