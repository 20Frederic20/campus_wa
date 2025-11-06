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
