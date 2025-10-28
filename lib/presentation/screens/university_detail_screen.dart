// import 'package:campus_wa/presentation/widgets/classroom_card.dart';
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
      appBar: AppBar(title: Text(univ.nom)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Informations textuelles ===
            Text(
              "Localisation : ${univ.slug}",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 20),
            // === Leaflet Maps ===

            SizedBox(
              height: 250,
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
                  zoom: 12,
                ),
              ),
            ),

            const SizedBox(height: 24),
            // === Liste des amphithéâtres ===
            Text(
              "Amphithéâtres (${univ.classrooms.length})",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 32),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    ...univ.classrooms.map((classroom) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Card(
                        child: ListTile(
                          leading: const Icon(Icons.meeting_room, color: Colors.red),
                          title: Text(
                            classroom.nom,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(classroom.slug),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => context.push('/classrooms/${classroom.id}'),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}