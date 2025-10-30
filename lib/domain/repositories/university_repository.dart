import 'package:campus_wa/domain/models/university.dart';

abstract class UniversityRepository {
  Future<List<University>> getUniversities();
  Future<University?> getUniversityById(String id);
  Future<List<University>> searchUniversities(String query);
}