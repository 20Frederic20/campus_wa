import 'package:json_annotation/json_annotation.dart';
import 'package:campus_wa/domain/models/university.dart';

part 'university_dto.g.dart';

@JsonSerializable()
class UniversityDto {
  final String id;
  final String name;
  final String slug;
  final String description;
  final double lng;
  final double lat;

  UniversityDto({
    required this.id,
    required this.name,
    required this.slug,
    this.description = '',
    required this.lng,
    required this.lat,
  });

  // Convertir le DTO en modèle de domaine
  University toDomain() {
    return University(
      id: id,
      name: name,
      slug: slug,
      description: description,
      lng: lng,
      lat: lat,
      classrooms: [], // Les salles de classe peuvent être chargées séparément
    );
  }

  // Désérialisation JSON
  factory UniversityDto.fromJson(Map<String, dynamic> json) =>
      _$UniversityDtoFromJson(json);

  // Sérialisation JSON
  Map<String, dynamic> toJson() => _$UniversityDtoToJson(this);
}