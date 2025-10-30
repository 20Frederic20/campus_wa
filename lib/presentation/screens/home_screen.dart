import 'package:flutter/material.dart';
import 'package:campus_wa/data/repositories/university_repository_impl.dart';
import 'package:campus_wa/domain/models/university.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_wa/domain/repositories/university_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UniversityRepository universityRepository = UniversityRepositoryImpl();
  late Future<List<University>> _universities;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Universités'),
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
          
          if (universities.isEmpty) {
            return const Center(
              child: Text('Aucune université trouvée'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: universities.length,
            itemBuilder: (context, index) {
              final university = universities[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(university.name),
                  subtitle: Text(university.slug),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push(
                    '/universities/${university.id}',
                    extra: universityRepository,
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