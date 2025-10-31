import 'dart:io';

import 'package:campus_wa/data/models/api/classroom_dto.dart';
import 'package:campus_wa/data/services/api_service.dart';
import 'package:campus_wa/domain/models/classroom.dart';
import 'package:campus_wa/domain/repositories/classroom_repository.dart';
import 'package:dio/dio.dart';

class ClassroomRepositoryImpl implements ClassroomRepository {
  final ApiService _apiService;
  final Map<String, Classroom> _cache = {};

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
        // _cache[createdClassroom.id] = createdClassroom;
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
      if (_cache.containsKey(id)) {
        return _cache[id]!;
      }
      final response = await _apiService.get('/classrooms/$id');
      if (response.data is Map && response.data['classroom'] is Map) {
        final classroom = ClassroomDto.fromJson(response.data['classroom']).toDomain();
        _cache[id] = classroom;
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
}
