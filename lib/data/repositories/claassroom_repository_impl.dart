import 'dart:io';

import 'package:campus_wa/data/models/api/classroom_dto.dart';
import 'package:campus_wa/data/services/api_service.dart';
import 'package:campus_wa/domain/models/classroom.dart';
import 'package:campus_wa/domain/repositories/classroom_repository.dart';
import 'package:dio/dio.dart';

class ClassroomRepositoryImpl implements ClassroomRepository {
  final ApiService _apiService;
  final Map<String, Classroom> _classroomCache = {};

  ClassroomRepositoryImpl({required ApiService apiService}) : _apiService = apiService;
  
  @override
  Future<Classroom> createClassroom(
    Classroom classroom,
    File? mainImage,
    {List<File> annexesImages = const []}
  ) async {
    try {
      final dto = ClassroomDto.create(
        universityId: classroom.universityId,
        name: classroom.name,
        slug: classroom.slug,
        lng: classroom.lng,
        lat: classroom.lat,
      );
      FormData formData = FormData.fromMap({
        ...dto.toJson(),
        if (mainImage != null)
          'main_image': await MultipartFile.fromFile(mainImage.path, filename: 'mainImage.jpg'),
        if (annexesImages.isNotEmpty)
          'annexes': await Future.wait(
            annexesImages.map((file) => MultipartFile.fromFile(file.path, filename: 'annexe_${annexesImages.indexOf(file)}.jpg')),
          ),
      });

      // Envoyer avec Dio
      final response = await _apiService.post('/classrooms', data: formData);

      if (response.data is Map && response.data['classroom'] is Map) {
        final createdClassroom = ClassroomDto.fromJson(response.data['classroom']).toDomain();
        _classroomCache[createdClassroom.id] = createdClassroom;
        return createdClassroom;
      }
      throw Exception('Format de réponse inattendu lors de la création de la salle');
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] ?? {};
        final errorMessage = errors.entries
            .map((e) => '${e.key}: ${e.value.join(', ')}')
            .join('\n');
        throw Exception(errorMessage.isNotEmpty ? errorMessage : 'Données invalides');
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
        final classroom = ClassroomDto.fromJson(response.data['classroom']).toDomain();
        _classroomCache[id] = classroom;
        return classroom;
      }
      throw Exception('Format de réponse inattendu');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Salle de classe non trouvée');
      }
      rethrow;
    }
  }

  @override
  Future<Classroom> updateClassroom(
    String id,
    Classroom classroom,
    File? mainImage, 
    {List<File> annexesImages = const []}
  ) async {
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
          'main_image': await MultipartFile.fromFile(mainImage.path, filename: 'mainImage.jpg'),
        if (annexesImages.isNotEmpty)
          'annexes[]': await Future.wait(
            annexesImages.map((file) => MultipartFile.fromFile(file.path, filename: 'annexe_${annexesImages.indexOf(file)}.jpg')),
          ),
      });

      final response = await _apiService.post('/classrooms/$id', data: formData);

      if (response.data is Map && response.data['classroom'] is Map) {
        final updatedClassroom = ClassroomDto.fromJson(response.data['classroom']).toDomain();
        _classroomCache[id] = updatedClassroom;
        return updatedClassroom;
      }
      throw Exception('Format de réponse inattendu lors de la mise à jour de la salle');
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] ?? {};
        final errorMessage = errors.entries
            .map((e) => '${e.key}: ${e.value.join(', ')}')
            .join('\n');
        throw Exception(errorMessage.isNotEmpty ? errorMessage : 'Données invalides');
      }
      rethrow;
    }
  }
}
