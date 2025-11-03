import 'package:campus_wa/core/exceptions/api_exception.dart';
import 'package:campus_wa/data/models/api/classroom_dto.dart';
import 'package:campus_wa/data/models/api/university_dto.dart';
import 'package:campus_wa/data/services/api_service.dart';
import 'package:campus_wa/domain/models/classroom.dart';
import 'package:campus_wa/domain/models/university.dart';
import 'package:campus_wa/domain/repositories/university_repository.dart';
import 'package:dio/dio.dart';



class UniversityRepositoryImpl implements UniversityRepository {
  final ApiService _apiService;
  final Map<String, University> _universityCache = {};
  final Map<String, Classroom> _classroomCache = {};

  UniversityRepositoryImpl({required ApiService apiService})
    : _apiService = apiService;

  @override
  Future<University> createUniversity(University university) async {
    try {
      final dto = UniversityDto.create(
        name: university.name,
        slug: university.slug,
        description: university.description,
        lng: university.lng,
        lat: university.lat,
        address: university.address,
      );
      final response = await _apiService.post('/universities', data: dto.toJson());
      if (response.data is Map && response.data['university'] is Map) {
        final createdUniversity = UniversityDto.fromJson(response.data['university']).toDomain();
        _universityCache[createdUniversity.id] = createdUniversity;
        return createdUniversity;
      }
      throw Exception('Format de réponse inattendu lors de la création de l\'université');

    } on DioException catch (e) {
      throw ApiException(
        message: 'Erreur lors de la création de l\'université: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }

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
            final List<University> list = universities.map((json) => UniversityDto.fromJson(json).toDomain()).toList();
            for (final university in list) {
              _universityCache[university.id] = university;
            }
            return list;
          } else if (response.data is List) {
            // Si la réponse est directement un tableau
            final List<dynamic> universities = response.data as List<dynamic>;
            if (universities.isEmpty) {
              return [];
            }
            final List<University> list = universities.map((json) => UniversityDto.fromJson(json).toDomain()).toList();
            for (final university in list) {
              _universityCache[university.id] = university;
            }
            return list;
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
    if (_universityCache.containsKey(id)) {
      return _universityCache[id]!;
    }

    try {
      final response = await _apiService.get('/universities/$id');
      if (response.data is Map && response.data['university'] is Map) {
        final university = UniversityDto.fromJson(response.data['university']).toDomain();
        _universityCache[id] = university;
        return university;
      }
      throw Exception('Format de réponse inattendue');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Université non trouvée');
      }
      rethrow;
    }
  }

  @override
  Future<List<Classroom>> getUniversityClassrooms(String id) async {
    try {
      // if (_universityCache.containsKey(id)) {
      //   return _universityCache[id]!.classrooms;
      // }
      final response = await _apiService.get('/universities/$id/classrooms');
      
      if (response.data is Map && response.data['classrooms'] != null) {
        final List<Classroom> list = (response.data['classrooms'] as List)
            .map((json) => ClassroomDto.fromJson(json).toDomain())
            .toList();
        for (final classroom in list) {
          _classroomCache[classroom.id] = classroom;
        }
        return list;
      } else if (response.data is List) {
        final List<Classroom> list = (response.data as List)
            .map((json) => ClassroomDto.fromJson(json).toDomain())
            .toList();
        for (final classroom in list) {
          _classroomCache[classroom.id] = classroom;
        }
        return list;
      } else if (response.data is Map && response.data['data'] != null) {
        final List<Classroom> list = (response.data['data'] as List)
            .map((json) => ClassroomDto.fromJson(json).toDomain())
            .toList();
        for (final classroom in list) {
          _classroomCache[classroom.id] = classroom;
        }
        return list;
      }
      
      throw Exception('Format de réponse inattendu');
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<List<University>> searchUniversities(String query) async {
    try {
      final response =
          await _apiService.get('/universities/search', params: {'q': query});

      if (response.data is List) {
        final List<University> list = (response.data as List)
            .map((json) => UniversityDto.fromJson(json).toDomain())
            .toList();
        for (final university in list) {
          _universityCache[university.id] = university;
        }
        return list;
      } else if (response.data is Map && response.data['data'] != null) {
        final List<University> list = (response.data['data'] as List)
            .map((json) => UniversityDto.fromJson(json).toDomain())
            .toList();
        for (final university in list) {
          _universityCache[university.id] = university;
        }                         
        return list;
      }

      throw Exception('Format de réponse inattendu');
    } on DioException {
      rethrow;
    }
  }
}