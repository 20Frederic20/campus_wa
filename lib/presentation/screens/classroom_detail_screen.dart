import 'package:campus_wa/domain/repositories/classroom_repository.dart';
import 'package:campus_wa/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:campus_wa/domain/models/classroom.dart';
import 'package:campus_wa/presentation/widgets/leaflet_map_widget.dart';

class ClassroomDetailScreen extends StatefulWidget {
  final String classroomId;
  const ClassroomDetailScreen({super.key, required this.classroomId});

  @override
  State<ClassroomDetailScreen> createState() => _ClassroomDetailScreenState();
}

class _ClassroomDetailScreenState extends State<ClassroomDetailScreen> {
  late Future<Classroom?> _classroomFuture;

  @override
  void initState() {
    super.initState();
    debugPrint('Initializing ClassroomDetailScreen with ID: ${widget.classroomId}');
    _loadClassroom();
  }

  Future<void> _loadClassroom() {
    setState(() {
      _classroomFuture = getIt<ClassroomRepository>().getClassroomById(widget.classroomId).then((classroom) {
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
      appBar: AppBar(title: const Text('Détails de la salle')),
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
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    classroom.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
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
                                  child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                                )
                              ]
                            : [],
                        zoom: hasValidCoords ? 16 : 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Retour"),
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