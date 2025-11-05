import 'package:campus_wa/domain/models/classroom.dart';
import 'package:campus_wa/domain/models/university.dart';

abstract class UniversityRepository {
  Future<University> createUniversity(University university);
  Future<List<University>?> getUniversities({String? query});
  Future<University?> getUniversityById(String id);
  Future<List<Classroom>?> getUniversityClassrooms(String id);
}
