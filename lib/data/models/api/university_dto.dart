import 'package:campus_wa/core/exceptions/api_exception.dart';
import 'package:campus_wa/domain/models/university.dart';
import 'package:json_annotation/json_annotation.dart';

part 'university_dto.g.dart';

@JsonSerializable()
class UniversityDto {
  @JsonKey()
  final String? id;
  @JsonKey()
  final String? name;
  @JsonKey()
  final String? slug;
  @JsonKey(name: 'created_at')
  final String? createdAtString;
  @JsonKey(name: 'updated_at')
  final String? updatedAtString;
  @JsonKey(name: 'classrooms_count')
  final int? classroomsCount;
  @JsonKey()
  final String? description;
  @JsonKey()
  final String? lng;
  @JsonKey()
  final String? lat;
  @JsonKey()
  final String? address;
  
  UniversityDto({
    this.id,
    this.name,
    this.slug,
    this.createdAtString,
    this.updatedAtString,
    this.classroomsCount,
    this.description,
    this.lng,
    this.lat,
    this.address,
  });

  DateTime? get createdAt => createdAtString != null ? DateTime.tryParse(createdAtString!) : null;
  DateTime? get updatedAt => updatedAtString != null ? DateTime.tryParse(updatedAtString!) : null;

  // Désérialisation JSON
  factory UniversityDto.fromJson(Map<String, dynamic> json) => _$UniversityDtoFromJson(json);

  // Sérialisation JSON
  Map<String, dynamic> toJson() => _$UniversityDtoToJson(this);

  // Factory pour la création d'une nouvelle université
  factory UniversityDto.create({
    required String name,
    required String slug,
    String description = '',
    String lng = '',
    String lat = '',
    String address = '',
  }) {
    return UniversityDto(
      name: name,
      slug: slug,
      description: description,
      lng: lng,
      lat: lat,
      address: address,
    );
  }

  // Convertir le DTO en modèle de domaine
  University toDomain() {
    if (id == null || name == null || slug == null) {
      throw ApiException(message: 'Missing required fields in University data');
    }
    
    final createdAt = this.createdAt ?? DateTime.now();
    final updatedAt = this.updatedAt ?? DateTime.now();
    
    return University(
      id: id!,
      name: name!,
      slug: slug!,
      createdAt: createdAt,
      updatedAt: updatedAt,
      description: description ?? '',
      lng: lng ?? '',
      lat: lat ?? '',
      address: address ?? '',
      classroomsCount: classroomsCount ?? 0,
      classrooms: const [], // Les salles de classe peuvent être chargées séparément
    );
  }

  factory UniversityDto.fromDomain(University university) {
    return UniversityDto(
      id: university.id,
      name: university.name,
      slug: university.slug,
      description: university.description,
      lng: university.lng,
      lat: university.lat,
      address: university.address,
      classroomsCount: university.classroomsCount,
      createdAtString: university.createdAt.toIso8601String(),
      updatedAtString: university.updatedAt.toIso8601String(),
    );
  }
}