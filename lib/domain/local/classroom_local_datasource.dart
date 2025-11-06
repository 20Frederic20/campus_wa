import 'package:campus_wa/data/models/api/classroom_dto.dart';

abstract class ClassroomLocalDataSource {
  Future<void> cacheClassrooms(List<ClassroomDto> classrooms);
  Future<List<ClassroomDto>?> getCachedClassrooms();
  Future<void> cacheClassroomsByUniversityId(
    String universityId,
    List<ClassroomDto> classrooms,
  );
  Future<List<ClassroomDto>?> getCachedClassroomsByUniversityId(
    String universityId,
  );
  Future<void> cacheClassroomById(String id, ClassroomDto classroom);
  Future<ClassroomDto?> getCachedClassroomById(String id);
  Future<void> cacheClassroomsByIds(
    List<String> ids,
    List<ClassroomDto> classrooms,
  );
  Future<List<ClassroomDto>?> getCachedClassroomsByIds(List<String> ids);
  Future<void> cacheRandomClassrooms(List<ClassroomDto> classrooms);
  Future<List<ClassroomDto>?> getCachedRandomClassrooms();
  Future<void> clearCache();
}
