import 'package:campus_wa/domain/models/classroom.dart';

abstract class ClassroomRepository {
  Future<Classroom> createClassroom(Classroom classroom);
  Future<Classroom?> getClassroomById(String id);
  
}
