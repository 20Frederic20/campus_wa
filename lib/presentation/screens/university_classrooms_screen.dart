import 'package:campus_wa/core/injection.dart' as di;
import 'package:campus_wa/core/theme/app_theme.dart';
import 'package:campus_wa/core/utils/error_utils.dart';
import 'package:campus_wa/domain/models/classroom.dart';
import 'package:campus_wa/domain/repositories/university_repository.dart';
import 'package:campus_wa/presentation/widgets/search_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UniversityClassroomsScreen extends StatefulWidget {

  final String universityId;
  final String universityName;

  const UniversityClassroomsScreen({
    super.key, 
    required this.universityId, 
    required this.universityName,
  });

  @override
  State<UniversityClassroomsScreen> createState() => _UniversityClassroomsScreen();
  
}

class _UniversityClassroomsScreen extends State<UniversityClassroomsScreen> {

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Classroom> _filterClassrooms(List<Classroom> classrooms, String query) {
    if (query.isEmpty) return classrooms;
    return classrooms.where((classroom) => 
      classroom.name.toLowerCase().contains(query.toLowerCase()) ||
      classroom.slug.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Amphi de ${widget.universityName}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBarWidget(
              controller: _searchController,
              hintText: 'Rechercher une salle...',
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Classroom>>(
        future: di.getIt<UniversityRepository>().getUniversityClassrooms(widget.universityId),
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
          
          final filteredClassrooms = _filterClassrooms(classrooms, _searchQuery);
          
          if (filteredClassrooms.isEmpty) {
            return const Center(
              child: Text("Aucune salle de classe disponible"),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _refreshData(context),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredClassrooms.length,
              itemBuilder: (context, index) {
                final classroom = filteredClassrooms[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: AppColors.white,
                    child: ListTile(
                      leading: const Icon(Icons.meeting_room, color: Colors.red),
                      title: Text(
                        classroom.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(classroom.slug),
                      trailing: const Icon(
                        Icons.arrow_forward_ios, 
                        size: 16,
                        color: AppColors.primaryGreen,
                      ),
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
      await di.getIt<UniversityRepository>().getUniversityClassrooms(widget.universityId);
      // La mise à jour de l'interface sera gérée par le FutureBuilder
    } catch (e) {
      // L'erreur sera capturée par le FutureBuilder
    }
  }
}