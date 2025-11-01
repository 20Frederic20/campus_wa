import 'package:campus_wa/core/injection.dart' as di;
import 'package:campus_wa/domain/models/classroom.dart';
import 'package:campus_wa/domain/repositories/classroom_repository.dart';
import 'package:campus_wa/presentation/widgets/image_display_widget.dart';
import 'package:campus_wa/presentation/widgets/leaflet_map_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:campus_wa/core/theme/app_theme.dart';


class ClassroomDetailScreen extends StatefulWidget {
  final String classroomId;
  const ClassroomDetailScreen({super.key, required this.classroomId});

  @override
  State<ClassroomDetailScreen> createState() => __$ClassroomDetailScreenState();
}

class __$ClassroomDetailScreenState extends State<ClassroomDetailScreen> {
  late Future<Classroom?> _classroomFuture;

  @override
  void initState() {
    super.initState();
    debugPrint('Initializing ClassroomDetailScreen with ID: ${widget.classroomId}');
    _loadClassroom();
  }

  Future<void> _loadClassroom() {
    setState(() {
      _classroomFuture = di.getIt<ClassroomRepository>().getClassroomById(widget.classroomId).then((classroom) {
        if (classroom == null) {
          throw Exception('Salle non trouvée');
        }
        debugPrint('Classroom data: $classroom'); // Ajoutez cette ligne
        return classroom;
      });
    });
    return _classroomFuture.catchError((error) {
      debugPrint('Error loading classroom: $error');
      throw error;
    });
  }

  // Future<void> _refreshClassroom() {
  //   setState(() {
  //     _classroomFuture = getIt<ClassroomRepository>()
  //         .getClassroomById(widget.classroomId)
  //         .then((classroom) {
  //       debugPrint('Classroom data: $classroom'); // Ajoutez cette ligne
  //       return classroom;
  //     });
  //   });
  //   return _classroomFuture.then((_) {});
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Détails de l’amphi',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: FutureBuilder<Classroom?>(
        future: _classroomFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.accentRed, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    snapshot.error?.toString() ?? 'Salle non trouvée',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadClassroom,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final classroom = snapshot.data!;
          final hasValidCoords = classroom.lat.isNotEmpty && classroom.lng.isNotEmpty;
          final coords = hasValidCoords 
              ? LatLng(
                  double.parse(classroom.lat), 
                  double.parse(classroom.lng),
                )
              : const LatLng(0, 0);

          debugPrint('Building UI for classroom: ${classroom.name}');
          return RefreshIndicator(
            onRefresh: _loadClassroom,
            color: AppColors.primaryGreen,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppColors.primaryGreen.withOpacity(0.2)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.meeting_room_outlined, color: AppColors.primaryGreen, size: 24),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              classroom.name + (classroom.name.isNotEmpty ? ' (' + classroom.slug + ')' : ''),
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Affichage de toutes les images dans un seul carrousel
                  if (classroom.mainImage.isNotEmpty || classroom.annexesImages.isNotEmpty) ...[
                    // Création d'une liste combinant l'image principale et les images annexes
                    // On filtre les éventuelles valeurs nulles ou vides
                    ImagesDisplayWidget(
                      imageUrls: [
                        if (classroom.mainImage.isNotEmpty) classroom.mainImage,
                        ...classroom.annexesImages.where((img) => img.isNotEmpty),
                      ],
                      height: 250,
                      enableCarousel: true,
                    ),
                    const SizedBox(height: 24),
                  ],
                  SizedBox(
                    height: 250,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: LeafletMapWidget(
                        center: coords,
                        markers: hasValidCoords
                            ? [
                                Marker(
                                  point: coords,
                                  width: 40,
                                  height: 40,
                                  child: const Icon(Icons.location_on, color: AppColors.accentRed, size: 48),
                                )
                              ]
                            : [],
                        zoom: hasValidCoords ? 16 : 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.map_outlined, size: 20),
                          label: const Text(
                            'Ouvrir dans Google Maps',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
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
                          label: const Text(
                            'Itinéraire',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
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
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text(
                              'Retour',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}