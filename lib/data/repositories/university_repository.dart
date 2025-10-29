import 'package:dio/dio.dart';
import '../models/api/university_dto.dart';
import '../services/api_service.dart';
import '../../domain/models/university.dart';

class UniversityRepository {
  final ApiService _apiService = ApiService();

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
}