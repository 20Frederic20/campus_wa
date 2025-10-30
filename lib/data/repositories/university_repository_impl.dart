import 'package:dio/dio.dart';
import 'package:campus_wa/data/models/api/university_dto.dart';
import 'package:campus_wa/data/services/api_service.dart';
import 'package:campus_wa/domain/models/university.dart';
import 'package:campus_wa/domain/repositories/university_repository.dart';
import 'package:campus_wa/core/exceptions/api_exception.dart';  // Ajoutez cette ligne

class UniversityRepositoryImpl implements UniversityRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<List<University>> getUniversities() async {
    try {
      final response = await _apiService.get('/universities');

      if (response.statusCode == 200) {
        try {
          // Vérifier si la réponse contient un tableau 'universities'
          if (response.data is Map && response.data['universities'] is List) {
            final List<dynamic> universities = response.data['universities'] as List<dynamic>;
            if (universities.isEmpty) {
              return [];
            }
            return universities.map((json) => UniversityDto.fromJson(json).toDomain()).toList();
          } else if (response.data is List) {
            // Si la réponse est directement un tableau
            final List<dynamic> universities = response.data as List<dynamic>;
            if (universities.isEmpty) {
              return [];
            }
            return universities.map((json) => UniversityDto.fromJson(json).toDomain()).toList();
          } else {
            throw ApiException(
              message: 'Format de réponse inattendu',
              statusCode: response.statusCode,
            );
          }
        } catch (e) {
          throw ApiException(
            message: 'Erreur lors du traitement des données: ${e.toString()}',
            statusCode: response.statusCode,
          );
        }
      }

      throw ApiException(
        message: 'Échec de la récupération des universités (${response.statusCode})',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      // Gestion spécifique des erreurs de connexion
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw ApiException(
          message: 'Erreur de connexion au serveur. Vérifiez votre connexion internet.',
          statusCode: 408, // Request Timeout
        );
      }
      // Autres erreurs Dio
      throw ApiException(
        message: 'Erreur réseau: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      // Toutes les autres erreurs
      throw ApiException(
        message: 'Erreur inattendue: ${e.toString()}',
      );
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