import 'package:campus_wa/domain/models/classroom.dart';

abstract class ClassroomRepository {
  Future<Classroom?> getClassroomById(String id);
}
