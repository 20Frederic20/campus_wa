import 'dart:io';

import 'package:campus_wa/domain/models/classroom.dart';

abstract class ClassroomRepository {
  Future<Classroom> createClassroom(
    Classroom classroom,
    File? mainImage, {
    List<File> annexesImages = const [],
  });
  Future<List<Classroom>?> getClassrooms({
    String? query,
    double? lat,
    double? lng,
  });
  Future<Classroom?> getClassroomById(String id);
  Future<List<Classroom>?> getRandomClassrooms({double? lat, double? lng});
  Future<Classroom> updateClassroom(
    String id,
    Classroom classroom,
    File? mainImage, {
    List<File> annexesImages = const [],
  });
}
