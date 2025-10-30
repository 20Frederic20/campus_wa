import 'package:json_annotation/json_annotation.dart';
import 'package:campus_wa/domain/models/university.dart';

part 'university_dto.g.dart';

@JsonSerializable()
class UniversityDto {
  final String id;
  final String name;
  final String slug;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description;
  final String? lng;
  final String? lat;
  final String? address;

  UniversityDto({
    required this.id,
    required this.name,
    required this.slug,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.lng,
    this.lat,
    this.address,
  });

  // Convertir le DTO en modèle de domaine
  University toDomain() {
    return University(
      id: id,
      name: name,
      slug: slug,
      createdAt: createdAt,
      updatedAt: updatedAt,
      description: description,
      lng: lng,
      lat: lat,
      address: address,
      classrooms: [], // Les salles de classe peuvent être chargées séparément
    );
  }

  // Désérialisation JSON
  factory UniversityDto.fromJson(Map<String, dynamic> json) =>
      _$UniversityDtoFromJson(json);

  // Sérialisation JSON
  Map<String, dynamic> toJson() => _$UniversityDtoToJson(this);
}