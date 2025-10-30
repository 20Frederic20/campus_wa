import 'package:campus_wa/main.dart';
import 'package:campus_wa/domain/repositories/university_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:campus_wa/presentation/widgets/leaflet_map_widget.dart';
import 'package:campus_wa/domain/models/university.dart';

class UniversityDetailScreen extends StatefulWidget {
  final String universityId;

  const UniversityDetailScreen({
    super.key,
    required this.universityId,
  });

  @override
  State<UniversityDetailScreen> createState() => _UniversityDetailScreenState();
}

class _UniversityDetailScreenState extends State<UniversityDetailScreen> {
  late Future<University> _universityFuture;

  @override
  void initState() {
    super.initState();
    _loadUniversity();
  }

  Future<void> _loadUniversity() {
    setState(() {
      _universityFuture = getIt<UniversityRepository>()
          .getUniversityById(widget.universityId)
          .then((university) {
        // S'assurer que l'université est valide
        if (university == null) {
          throw Exception('Université non trouvée');
        }
        return university;
      });
    });
    return _universityFuture.catchError((error) {
      debugPrint('Error loading university: $error');
      throw error;
    });
  }

  void _refresh() {
    _loadUniversity();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<University>(
      future: _universityFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        final university = snapshot.data!;
        return _buildContent(context, university);
      },
    );
  }

  Widget _buildContent(BuildContext context, University university) {
    final hasValidCoords = university.lat.isNotEmpty && 
                         university.lng.isNotEmpty;

    final coords = hasValidCoords 
        ? LatLng(
            double.parse(university.lat), 
            double.parse(university.lng),
          )
        : const LatLng(0, 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(university.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte
            SizedBox(
              height: 300,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: LeafletMapWidget(
                  center: coords,
                  zoom: hasValidCoords ? 12 : 2,
                  markers: hasValidCoords
                      ? [
                          Marker(
                            point: coords,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ]
                      : [],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Informations de base
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Détails',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.link, 'Slug', university.slug),
                    if (university.description.isNotEmpty)
                      _buildInfoRow(
                        Icons.description,
                        'Description',
                        university.description,
                      ),
                    _buildInfoRow(
                      Icons.location_on,
                      'Coordonnées',
                      hasValidCoords 
                          ? 'Lat: ${coords.latitude.toStringAsFixed(4)}, Lng: ${coords.longitude.toStringAsFixed(4)}'
                          : 'Non disponible',
                    ),
                  ],
                ),
              ),
            ),

            // Bouton pour voir les salles de classe
            if (university.classroomsCount > 0) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.meeting_room),
                  label: Text(
                    'Voir les salles de classe (${university.classroomsCount})',
                  ),
                  onPressed: () => context.push(
                    '/universities/${university.id}/classrooms',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}