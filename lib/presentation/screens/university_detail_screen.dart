import 'package:campus_wa/domain/extensions/location_extension.dart';
import 'package:flutter/material.dart';
import 'package:campus_wa/data/mock_data.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_wa/presentation/widgets/leaflet_map_widget.dart';


class UniversityDetailScreen extends StatelessWidget {
  final String universityId;
  const UniversityDetailScreen({super.key, required this.universityId});

  @override
  Widget build(BuildContext context) {
    final univ = universities.firstWhere((u) {
      return u.id == universityId;
    });

    return Scaffold(
      appBar: AppBar(title: Text(univ.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Images ===
            // if (univ.imageUrls != null && univ.imageUrls!.isNotEmpty)
            //   ImagesDisplayWidget(
            //     imageUrls: univ.imageUrls!,
            //     enableCarousel: true,
            //     allowMultipleImages: true,
            //     height: 200, // taille fixe
            //   ),
            // const SizedBox(height: 16),

            // === Infos textuelles ===
            Text(
              "Localisation : ${univ.slug}",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),

            // === Carte ===
            SizedBox(
              height: 250, // taille fixe
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: LeafletMapWidget(
                  center: univ.coords,
                  markers: [
                    Marker(
                      point: univ.coords,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    )
                  ],
                  zoom: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // === Résumé des amphithéâtres ===
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.meeting_room, color: Colors.red),
                title: Text(
                  "Amphithéâtres",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text("${univ.classrooms?.length} amphithéâtres disponibles"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/universities/${univ.id}/classrooms'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}