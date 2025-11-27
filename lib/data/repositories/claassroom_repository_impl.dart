import 'dart:io';

import 'package:campus_wa/data/models/api/classroom_dto.dart';
import 'package:campus_wa/data/services/api_service.dart';
import 'package:campus_wa/domain/local/classroom_local_datasource.dart';
import 'package:campus_wa/domain/models/classroom.dart';
import 'package:campus_wa/domain/repositories/classroom_repository.dart';
import 'package:dio/dio.dart';

class ClassroomRepositoryImpl implements ClassroomRepository {
  ClassroomRepositoryImpl({
    required ApiService apiService,
    required ClassroomLocalDataSource classroomLocal,
  }) : _apiService = apiService,
       _classroomLocal = classroomLocal;

  final ApiService _apiService;
  final ClassroomLocalDataSource _classroomLocal;
  final Map<String, Classroom> _classroomCache = {};

  // Helper : est-ce une erreur réseau ?
  bool _isNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.error is SocketException;
  }

  @override
  Future<Classroom> createClassroom(
    Classroom classroom,
    File? mainImage, {
    List<File> annexesImages = const [],
  }) async {
    try {
      final dto = ClassroomDto.create(
        universityId: classroom.universityId,
        name: classroom.name,
        slug: classroom.slug,
        lng: classroom.lng,
        lat: classroom.lat,
      );
      final FormData formData = FormData.fromMap({
        ...dto.toJson(),
        if (mainImage != null)
          'main_image': await MultipartFile.fromFile(
            mainImage.path,
            filename: 'mainImage.jpg',
          ),
        if (annexesImages.isNotEmpty)
          'annexes[]': await Future.wait(
            annexesImages.map(
              (file) => MultipartFile.fromFile(
                file.path,
                filename: 'annexe_${annexesImages.indexOf(file)}.jpg',
              ),
            ),
          ),
      });

      // Envoyer avec Dio
      final response = await _apiService.post('/classrooms', data: formData);

      if (response.data is Map && response.data['classroom'] is Map) {
        final createdClassroom = ClassroomDto.fromJson(
          response.data['classroom'],
        ).toDomain();
        _classroomCache[createdClassroom.id] = createdClassroom;
        return createdClassroom;
      }
      throw Exception(
        'Format de réponse inattendu lors de la création de la salle',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] ?? {};
        final errorMessage = errors.entries
            .map((e) => '${e.key}: ${e.value.join(', ')}')
            .join('\n');
        throw Exception(
          errorMessage.isNotEmpty ? errorMessage : 'Données invalides',
        );
      }
      rethrow;
    }
  }

  @override
  Future<Classroom?> getClassroomById(String id) async {
    try {
      if (_classroomCache.containsKey(id)) {
        return _classroomCache[id]!;
      }
      final response = await _apiService.get('/classrooms/$id');
      if (response.data is Map && response.data['classroom'] is Map) {
        final classroom = ClassroomDto.fromJson(response.data['classroom']);
        await _classroomLocal.cacheClassroomById(id, classroom);
        return classroom.toDomain();
      }
      throw Exception('Format de réponse inattendu');
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        final classroom = await _classroomLocal.getCachedClassroomById(id);
        if (classroom == null) return null;
        return classroom.toDomain();
      }
      return null;
    }
  }

  @override
  Future<Classroom> updateClassroom(
    String id,
    Classroom classroom,
    File? mainImage, {
    List<File> annexesImages = const [],
  }) async {
    try {
      final dto = ClassroomDto.create(
        universityId: classroom.universityId,
        name: classroom.name,
        slug: classroom.slug,
        lng: classroom.lng,
        lat: classroom.lat,
      );

      if (_classroomCache.containsKey(id)) {
        _classroomCache.remove(id);
      }

      final FormData formData = FormData.fromMap({
        ...dto.toJson(),
        '_method': 'PUT', // Important pour les mises à jour
        if (mainImage != null)
          'main_image': await MultipartFile.fromFile(
            mainImage.path,
            filename: 'mainImage.jpg',
          ),
        if (annexesImages.isNotEmpty)
          'annexes[]': await Future.wait(
            annexesImages.map(
              (file) => MultipartFile.fromFile(
                file.path,
                filename: 'annexe_${annexesImages.indexOf(file)}.jpg',
              ),
            ),
          ),
      });

      final response = await _apiService.post(
        '/classrooms/$id',
        data: formData,
      );

      if (response.data is Map && response.data['classroom'] is Map) {
        final updatedClassroom = ClassroomDto.fromJson(
          response.data['classroom'],
        ).toDomain();
        _classroomCache[id] = updatedClassroom;
        return updatedClassroom;
      }
      throw Exception(
        'Format de réponse inattendu lors de la mise à jour de la salle',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] ?? {};
        final errorMessage = errors.entries
            .map((e) => '${e.key}: ${e.value.join(', ')}')
            .join('\n');
        throw Exception(
          errorMessage.isNotEmpty ? errorMessage : 'Données invalides',
        );
      }
      rethrow;
    }
  }

  @override
  Future<List<Classroom>?> getClassrooms({String? query}) async {
    try {
      final response = await _apiService.get(
        '/classrooms?',
        params: query != null ? {'search': query} : null,
      );
      if (response.data is Map<String, dynamic> &&
          response.data['classrooms'] is List) {
        final List<dynamic> jsonList =
            response.data['classrooms'] as List<dynamic>;
        final List<ClassroomDto> dtos = jsonList
            .map<ClassroomDto>(
              (dynamic j) => ClassroomDto.fromJson(j as Map<String, dynamic>),
            )
            .toList();
        final List<Classroom> domainList = dtos
            .map<Classroom>((ClassroomDto d) => d.toDomain())
            .toList();
        return domainList;
      }
      return null;
    } on DioException catch (e) {
      if (_isNetworkError(e)) return null;
      rethrow;
    }
  }

  @override
  Future<List<Classroom>?> getRandomClassrooms() async {
    try {
      final response = await _apiService.get('/classrooms/random');
      if (response.data is Map<String, dynamic> &&
          response.data['classrooms'] is List) {
        final List<dynamic> jsonList =
            response.data['classrooms'] as List<dynamic>;
        final List<ClassroomDto> dtos = jsonList
            .map<ClassroomDto>(
              (dynamic j) => ClassroomDto.fromJson(j as Map<String, dynamic>),
            )
            .toList();
        final List<Classroom> domainList = dtos
            .map<Classroom>((ClassroomDto d) => d.toDomain())
            .toList();
        await _classroomLocal.cacheRandomClassrooms(dtos);
        return domainList;
      }
      return null;
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        final randomClassrooms = await _classroomLocal
            .getCachedRandomClassrooms();
        if (randomClassrooms != null) {
          return randomClassrooms.map((c) => c.toDomain()).toList();
        }
      }
      return null;
    }
  }
}
