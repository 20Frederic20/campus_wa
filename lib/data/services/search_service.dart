import 'dart:developer'; // Add this if not already imported

import 'package:campus_wa/domain/adapters/classroom_adapter.dart';
import 'package:campus_wa/domain/adapters/university_adapter.dart';
import 'package:campus_wa/domain/entities/searchable_item.dart';
import 'package:campus_wa/domain/repositories/classroom_repository.dart';
import 'package:campus_wa/domain/repositories/university_repository.dart';

class SearchService {
  SearchService(this._universityRepository, this._classroomRepository);
  final UniversityRepository _universityRepository;
  final ClassroomRepository _classroomRepository;

  Future<List<SearchableItem>> search(String query) async {
    try {
      // Exécuter les appels en parallèle
      final results = await Future.wait([
        _searchUniversities(query),
        _searchClassrooms(query),
      ], eagerError: true);

      // Fusionner et trier les résultats
      final combined = results.expand((list) => list).toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      log('Combined search results for "$query": ${combined.length} items');
      return combined;
    } catch (e) {
      // Gérer les erreurs de manière appropriée
      log('Erreur lors de la recherche: $e');
      return [];
    }
  }

  Future<List<SearchableItem>> _searchUniversities(String query) async {
    final universities = await _universityRepository.getUniversities(
      query: query,
    );
    log('Raw universities fetched: ${universities?.length ?? 0}');
    final results =
        universities?.map((u) => UniversityAdapter(u)).toList() ?? [];
    log('results for universites search: ${results.toString()}');
    return results;
  }

  Future<List<SearchableItem>> _searchClassrooms(String query) async {
    try {
      final classrooms = await _classroomRepository.getClassrooms(query: query);
      if (classrooms == null) {
        log('No classrooms found for query: $query');
        return [];
      }
      log('Raw classrooms fetched for "$query": ${classrooms.length}');
      final results = classrooms.map((c) => ClassroomAdapter(c)).toList();
      log('results for classrooms search: $results');
      return results;
    } catch (e) {
      log('Error in _searchClassrooms: $e');
      return [];
    }
  }
}
