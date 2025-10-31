import 'package:campus_wa/domain/models/classroom.dart';
import 'dart:io';

abstract class ClassroomRepository {
  Future<Classroom> createClassroom(
    Classroom classroom,
    File? mainImage,
    {List<File> annexesImages = const []});
  Future<Classroom?> getClassroomById(String id);
  
}
