import 'classroom.dart';

class University {
  final String id;
  final String name;
  final String slug;
  final double lng;
  final double lat;
  final List<Classroom> classrooms;
  final List<String>? imageUrls;

  University({
    required this.id,
    required this.name,
    required this.slug,
    required this.lng,
    required this.lat,
    required this.classrooms,
    this.imageUrls,
  });
}