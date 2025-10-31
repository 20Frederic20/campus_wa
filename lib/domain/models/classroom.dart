import 'package:equatable/equatable.dart';

class Classroom extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String lng;
  final String lat ;
  final String universityId;
  final String mainImage;
  final List<String> annexesImages;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Classroom({
    required this.id,
    required this.name,
    required this.slug,
    this.lng = '',
    this.lat = '',
    this.universityId = '',
    this.mainImage = '',
    this.annexesImages = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    lng,
    lat,
    universityId,
    mainImage,
    annexesImages,
    createdAt,
    updatedAt,
  ];
}