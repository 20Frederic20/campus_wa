import 'package:campus_wa/data/models/api/university_dto.dart';

abstract class UniversityLocalDataSource {
  Future<void> cacheUniversities(List<UniversityDto> universities);
  Future<List<UniversityDto>?> getCachedUniversities();
  Future<void> clearCache();
}