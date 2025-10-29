import 'classroom.dart';

class University {
  final String id;
  final String name;
  final String slug;
  final String description;
  final double lng;
  final double lat;
  final List<Classroom> classrooms;

  University({
    required this.id,
    required this.name,
    required this.slug,
    this.description = '',
    required this.lng,
    required this.lat,
    required this.classrooms,
  });
}