import 'package:campus_wa/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_wa/domain/models/classroom.dart';
import 'package:campus_wa/domain/repositories/university_repository.dart';
import 'package:campus_wa/core/utils/error_utils.dart';

class UniversityClassroomsScreen extends StatelessWidget {
  final String universityId;
  final String universityName;

  const UniversityClassroomsScreen({
    super.key, 
    required this.universityId, 
    required this.universityName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Salles de $universityName'),
      ),
      body: FutureBuilder<List<Classroom>>(
        future: getIt<UniversityRepository>().getUniversityClassrooms(universityId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement des salles de classe',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    getErrorMessage(snapshot.error),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _refreshData(context),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final classrooms = snapshot.data ?? [];
          
          if (classrooms.isEmpty) {
            return const Center(
              child: Text("Aucune salle de classe disponible"),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _refreshData(context),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: classrooms.length,
              itemBuilder: (context, index) {
                final classroom = classrooms[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.meeting_room, color: Colors.red),
                      title: Text(
                        classroom.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(classroom.slug),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => context.push('/classrooms/${classroom.id}'),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _refreshData(BuildContext context) async {
    try {
      await getIt<UniversityRepository>().getUniversityClassrooms(universityId);
      // La mise à jour de l'interface sera gérée par le FutureBuilder
    } catch (e) {
      // L'erreur sera capturée par le FutureBuilder
    }
  }
}