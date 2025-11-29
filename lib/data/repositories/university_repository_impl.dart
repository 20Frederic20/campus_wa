import 'dart:developer';
import 'dart:io'; // Pour SocketException
import 'package:campus_wa/core/exceptions/api_exception.dart';
import 'package:campus_wa/data/models/api/classroom_dto.dart';
import 'package:campus_wa/data/models/api/university_dto.dart';
import 'package:campus_wa/data/services/api_service.dart';
import 'package:campus_wa/domain/local/classroom_local_datasource.dart';
import 'package:campus_wa/domain/local/university_local_datasource.dart';
import 'package:campus_wa/domain/models/classroom.dart';
import 'package:campus_wa/domain/models/university.dart';
import 'package:campus_wa/domain/repositories/university_repository.dart';
import 'package:dio/dio.dart';

class UniversityRepositoryImpl implements UniversityRepository {
  UniversityRepositoryImpl({
    required ApiService apiService,
    required UniversityLocalDataSource universityLocal,
    required ClassroomLocalDataSource classroomLocal,
  }) : _apiService = apiService,
       _universityLocal = universityLocal,
       _classroomLocal = classroomLocal;
  final ApiService _apiService;
  final UniversityLocalDataSource _universityLocal;
  final ClassroomLocalDataSource _classroomLocal;

  // Helper : est-ce une erreur réseau ?
  bool _isNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.error is SocketException;
  }

  @override
  Future<University> createUniversity(University university) async {
    // Pas de fallback pour création (besoin serveur)
    try {
      final dto = UniversityDto.create(
        name: university.name,
        slug: university.slug,
        description: university.description,
        lng: university.lng,
        lat: university.lat,
        address: university.address,
      );
      final response = await _apiService.post(
        '/universities',
        data: dto.toJson(),
      );
      if (response.data is Map && response.data['university'] is Map) {
        final universityDto = UniversityDto.fromJson(
          response.data['university'],
        );
        final created = universityDto.toDomain();

        // Mise à jour cache local (rafraîchir liste)
        final remoteList = await getUniversities(); // ignore fallback ici
        if (remoteList != null) {
          await _universityLocal.cacheUniversities(
            remoteList.map(UniversityDto.fromDomain).toList(),
          );
        } else {
          // Handle the case where remoteList is null, maybe log a warning or skip caching
          log('Warning: Could not fetch universities list for caching');
        }
        return created;
      }
      throw Exception('Format de réponse inattendu');
    } on DioException catch (e) {
      throw ApiException(
        message: 'Erreur lors de la création: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<University>?> getUniversities({String? query}) async {
    try {
      final response = await _apiService
          .get(
            '/universities',
            params: query != null ? {'search': query} : null,
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        List<dynamic> rawList = [];
        if (response.data is Map && response.data['universities'] is List) {
          rawList = response.data['universities'];
        } else if (response.data is List) {
          rawList = response.data;
        } else {
          throw ApiException(message: 'Format inattendu', statusCode: 200);
        }

        final dtos = rawList
            .map((j) => UniversityDto.fromJson(j as Map<String, dynamic>))
            .toList();
        final domainList = dtos.map((d) => d.toDomain()).toList();

        // Cache persistant
        await _universityLocal.cacheUniversities(dtos);

        return domainList;
      }
      throw ApiException(
        message: 'Échec (${response.statusCode})',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        // Fallback local
        final cachedDtos = await _universityLocal.getCachedUniversities();
        if (cachedDtos == null) return null;
        return cachedDtos.map((d) => d.toDomain()).toList();
      }
      throw ApiException(
        message: 'Erreur réseau: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ApiException(message: 'Erreur inattendue: $e');
    }
  }

  @override
  Future<University?> getUniversityById(String id) async {
    try {
      final response = await _apiService.get('/universities/$id');
      if (response.data is Map && response.data['university'] is Map) {
        final university = UniversityDto.fromJson(
          response.data['university'],
        ).toDomain();
        return university;
      }
      return null;
    } on DioException catch (e) {
      if (_isNetworkError(e)) return null;
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<List<Classroom>?> getUniversityClassrooms(String universityId) async {
    try {
      final response = await _apiService.get(
        '/universities/$universityId/classrooms',
      );

      List<dynamic> rawList = [];
      if (response.data is Map && response.data['classrooms'] is List) {
        rawList = response.data['classrooms'];
      } else if (response.data is List) {
        rawList = response.data;
      } else if (response.data is Map && response.data['data'] is List) {
        rawList = response.data['data'];
      } else {
        throw Exception('Format inattendu');
      }

      final dtos = rawList
          .map((j) => ClassroomDto.fromJson(j as Map<String, dynamic>))
          .toList();
      final domainList = dtos.map((d) => d.toDomain()).toList();

      // Cache persistant
      await _classroomLocal.cacheClassroomsByUniversityId(universityId, dtos);

      return domainList;
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        final cachedDtos = await _classroomLocal
            .getCachedClassroomsByUniversityId(universityId);
        if (cachedDtos == null) return null;
        return cachedDtos.map((d) => d.toDomain()).toList();
      }
      rethrow;
    }
  }
}
