import 'package:dio/dio.dart';
import 'package:campus_wa/data/models/api/university_dto.dart';
import 'package:campus_wa/data/services/api_service.dart';
import 'package:campus_wa/domain/models/university.dart';
import 'package:campus_wa/domain/repositories/university_repository.dart';

class UniversityRepositoryImpl implements UniversityRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<List<University>> getUniversities() async {
    try {
      final response = await _apiService.get('/universities');

      // Si l'API renvoie une liste d'universités
      if (response.data is List) {
        return (response.data as List)
            .map((json) => UniversityDto.fromJson(json).toDomain())
            .toList();
      }
      // Si l'API renvoie un objet avec une propriété 'data' contenant la liste
      else if (response.data is Map && response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((json) => UniversityDto.fromJson(json).toDomain())
            .toList();
      }

      throw Exception('Format de réponse inattendu');
    } on DioException catch (e) {
      // Gestion des erreurs spécifiques
      if (e.response?.statusCode == 404) {
        throw Exception('Aucune université trouvée');
      }
      rethrow;
    }
  }

  @override
  Future<University> getUniversityById(String id) async {
    try {
      final response = await _apiService.get('/universities/$id');
      return UniversityDto.fromJson(response.data).toDomain();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Université non trouvée');
      }
      rethrow;
    }
  }

  @override
  Future<List<University>> searchUniversities(String query) async {
    try {
      final response =
          await _apiService.get('/universities/search', params: {'q': query});

      if (response.data is List) {
        return (response.data as List)
            .map((json) => UniversityDto.fromJson(json).toDomain())
            .toList();
      } else if (response.data is Map && response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((json) => UniversityDto.fromJson(json).toDomain())
            .toList();
      }

      throw Exception('Format de réponse inattendu');
    } on DioException catch (e) {
      rethrow;
    }
  }
}