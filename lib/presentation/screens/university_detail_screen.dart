import 'package:campus_wa/core/injection.dart' as di;
import 'package:campus_wa/domain/models/university.dart';
import 'package:campus_wa/domain/repositories/university_repository.dart';
import 'package:campus_wa/presentation/widgets/leaflet_map_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:campus_wa/core/theme/app_theme.dart';

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
  late Future<University?> _universityFuture;

  @override
  void initState() {
    super.initState();
    _universityFuture = _loadUniversity();
  }

  Future<University?> _loadUniversity() async {
    try {
      final university = await di.getIt<UniversityRepository>()
          .getUniversityById(widget.universityId);
      return university;
    } catch (error) {
      debugPrint('Error loading university: $error');
      rethrow;
    }
  }

  void _refresh() {
    setState(() {
      _universityFuture = _loadUniversity();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<University?>(
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
        title: Text(
          university.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refresh,
            tooltip: 'Rafraîchir',
          ),
        ],
        elevation: 0,
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
                              color: AppColors.accentRed,
                              size: 48,
                            ),
                          ),
                        ]
                      : [],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.map_outlined, size: 20),
                    label: const Text('Ouvrir dans Google Maps', 
                      style: TextStyle(fontWeight: FontWeight.w500)),
                    onPressed: hasValidCoords ? () async {
                      try {
                        final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${coords.latitude},${coords.longitude}');
                        final canLaunch = await canLaunchUrl(url);
                        if (canLaunch) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                          if (!mounted) return;
                          // Essayer d'ouvrir directement avec l'application par défaut
                          await launchUrl(url, mode: LaunchMode.externalNonBrowserApplication);
                        }
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur: ${e.toString()}')),
                        );
                      }
                    } : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.directions_outlined, size: 20),
                    label: const Text('Itinéraire',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                    onPressed: hasValidCoords ? () {
                      // Redirection vers l'écran de développement
                      context.push('/geolocation', extra: 'Fonctionnalité d\'itinéraire en cours de développement');
                    } : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Informations de base
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, 
                          color: AppColors.primaryGreen),
                        const SizedBox(width: 8),
                        Text(
                          'Détails',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
                  icon: const Icon(Icons.meeting_room_outlined, 
                    color: Colors.white),
                  label: Text(
                    'Voir la liste des amphi(${university.classroomsCount})',
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}