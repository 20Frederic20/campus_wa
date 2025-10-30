import 'package:equatable/equatable.dart';
import 'classroom.dart';

class University extends Equatable {
  final String id;
  final String name;
  final String slug;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String description;
  final String lng;
  final String lat;
  final String address;
  final List<Classroom> classrooms;

  const University({
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
  
  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    createdAt,
    updatedAt,
    description,
    lng,
    lat,
    address,
    classrooms,
  ];
}