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
