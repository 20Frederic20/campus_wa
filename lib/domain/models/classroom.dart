import 'package:equatable/equatable.dart';

class Classroom extends Equatable {
  const Classroom({
    required this.id,
    required this.name,
    required this.slug,
    this.lng = '',
    this.lat = '',
    this.universityId = '',
    this.UniversityName = '',
    this.mainImage = '',
    this.annexesImages = const [],
    required this.createdAt,
    required this.updatedAt,
  });
  final String id;
  final String name;
  final String slug;
  final String lng;
  final String lat;
  final String universityId;
  final String UniversityName;
  final String mainImage;
  final List<String> annexesImages;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    lng,
    lat,
    universityId,
    UniversityName,
    mainImage,
    annexesImages,
    createdAt,
    updatedAt,
  ];
}
