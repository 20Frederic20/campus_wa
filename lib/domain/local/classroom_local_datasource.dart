import 'package:campus_wa/data/models/api/classroom_dto.dart';

abstract class ClassroomLocalDataSource {
  Future<void> cacheClassrooms(List<ClassroomDto> classrooms);
  Future<List<ClassroomDto>?> getCachedClassrooms();
  Future<void> cacheClassroomsByUniversityId(String universityId, List<ClassroomDto> classrooms);
  Future<List<ClassroomDto>?> getCachedClassroomsByUniversityId(String universityId);
  Future<void> clearCache();
}
