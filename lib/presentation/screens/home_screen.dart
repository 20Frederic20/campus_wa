import 'package:flutter/material.dart';
import 'package:campus_wa/data/repositories/university_repository_impl.dart';
import 'package:campus_wa/domain/models/university.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _universityRepository = UniversityRepositoryImpl();
  late Future<List<University>> _universities;

  @override
  void initState() {
    super.initState();
    _universities = _universityRepository.getUniversities();
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
              child: Text(
                'Erreur de chargement: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final universities = snapshot.data!;

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
                  onTap: () => context.push('/universities/${university.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}