import 'classroom.dart';

class University {
  final String id;
  final String name;
  final String slug;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description;
  final String? lng;
  final String? lat;
  final String? address;
  final List<Classroom>? classrooms;

  University({
    required this.id,
    required this.name,
    required this.slug,
    required this.createdAt,
    required this.updatedAt,
    this.description = '',
    this.lng = '',
    this.lat = '',
    this.address = '',
    this.classrooms = const [],
  });
}