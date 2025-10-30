import 'package:campus_wa/domain/models/university.dart';
import 'package:campus_wa/domain/models/classroom.dart';
import 'package:dio/dio.dart';

abstract class UniversityRepository {
  Future<Response<dynamic>> createUniversity(University university);
  Future<List<University>> getUniversities();
  Future<University?> getUniversityById(String id);
  Future<List<Classroom>> getUniversityClassrooms(String id);
  Future<List<University>> searchUniversities(String query);
}