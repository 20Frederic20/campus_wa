import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_wa/data/mock_data.dart';
import 'package:campus_wa/presentation/widgets/leaflet_map_widget.dart';

class ClassroomDetailScreen extends StatelessWidget {
  final String classroomId;
  const ClassroomDetailScreen({super.key, required this.classroomId});

  @override
  Widget build(BuildContext context) {
    final classroom = universities
        .expand((u) => u.classrooms.toList() ?? [] )
        .firstWhere((a) => a.id == classroomId);

    return Scaffold(
      appBar: AppBar(title: Text(classroom.nom)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: LeafletMapWidget(
                  center: classroom.coords,
                  markers: [
                    Marker(
                      point: classroom.coords,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    )
                  ],
                  zoom: 12,
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text("Retour"),
            ),
          ],
        ),
      ),
    );
  }
}