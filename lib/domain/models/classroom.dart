import 'package:equatable/equatable.dart';

class Classroom extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String lng;
  final String lat ;
  final String mainImage;
  final List<String> annexesImages;

  const Classroom({
    required this.id,
    required this.name,
    required this.slug,
    this.lng = '',
    this.lat = '',
    this.mainImage = '',
    this.annexesImages = const [],
  });

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    lng,
    lat,
    mainImage,
    annexesImages,
  ];
}