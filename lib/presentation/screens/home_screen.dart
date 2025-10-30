import 'package:campus_wa/main.dart';
import 'package:flutter/material.dart';
import 'package:campus_wa/domain/models/university.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_wa/domain/repositories/university_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final UniversityRepository universityRepository;
  late Future<List<University>> _universities;

  @override
  void initState() {
    super.initState();
    universityRepository = getIt<UniversityRepository>();
    _loadUniversities();
  }

  Future<void> _loadUniversities() {
    setState(() {
      _universities = universityRepository.getUniversities();
    });
    return _universities.catchError((error) {
      debugPrint('Error loading universities: $error');
      return [];
    });
  }

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<University> _filterUniversities(List<University> universities, String query) {
    if (query.isEmpty) return universities;
    return universities.where((univ) => 
      univ.name.toLowerCase().contains(query.toLowerCase()) ||
      univ.slug.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.school),
                title: const Text('Ajouter une université'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/universities/add').then((shouldRefresh) {
                    if (shouldRefresh == true) {
                      // Refresh the universities list
                      _loadUniversities();
                    }
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.meeting_room),
                title: const Text('Ajouter une salle'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/classrooms/add');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenu(context),
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Universités'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une université...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<University>>(
        future: _universities,
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
                    'Erreur de chargement: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                    onPressed: _loadUniversities,
                  ),
                ],
              ),
            );
          }

          final universities = snapshot.data ?? [];
          final filteredUniversities = _filterUniversities(universities, _searchQuery);
          
          if (filteredUniversities.isEmpty) {
            return const Center(
              child: Text('Aucune université trouvée'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredUniversities.length,
            itemBuilder: (context, index) {
              final university = filteredUniversities[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(university.name),
                  subtitle: Text(university.slug),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push(
                    '/universities/${university.id}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}