import 'package:json_annotation/json_annotation.dart';
import '../../../domain/models/university.dart';

part 'university_dto.g.dart';

@JsonSerializable()
class UniversityDto {
  final String id;
  final String nom;
  final String slug;
  final double lng;
  final double lat;
  final List<String>? imageUrls;

  UniversityDto({
    required this.id,
    required this.nom,
    required this.slug,
    required this.lng,
    required this.lat,
    this.imageUrls,
  });

  // Convertir le DTO en modèle de domaine
  University toDomain() {
    return University(
      id: id,
      nom: nom,
      slug: slug,
      lng: lng,
      lat: lat,
      classrooms: [], // Les salles de classe peuvent être chargées séparément
      imageUrls: imageUrls,
    );
  }

  // Désérialisation JSON
  factory UniversityDto.fromJson(Map<String, dynamic> json) => 
      _$UniversityDtoFromJson(json);
  
  // Sérialisation JSON
  Map<String, dynamic> toJson() => _$UniversityDtoToJson(this);
}