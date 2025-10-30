import 'package:json_annotation/json_annotation.dart';
import 'package:campus_wa/domain/models/classroom.dart';
import 'package:campus_wa/core/exceptions/api_exception.dart';

part 'classroom_dto.g.dart';

@JsonSerializable()
class ClassroomDto {
  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'slug')
  final String? slug;

  @JsonKey(name: 'lng')
  final String? lng;

  @JsonKey(name: 'lat')
  final String? lat;

  @JsonKey(name: 'main_image')
  final String? mainImage;

  @JsonKey(name: 'annexes_images')
  final List<String>? annexesImages;

  @JsonKey(name: 'created_at')
  final String? createdAtString;

  @JsonKey(name: 'updated_at')
  final String? updatedAtString;

  DateTime? get createdAt => createdAtString != null ? DateTime.tryParse(createdAtString!) : null;
  DateTime? get updatedAt => updatedAtString != null ? DateTime.tryParse(updatedAtString!) : null;

  const ClassroomDto({
    this.id,
    this.name,
    this.slug,
    this.lng,
    this.lat,
    this.mainImage,
    this.annexesImages,
    this.createdAtString,
    this.updatedAtString,
  });

  Classroom toDomain() {
    if (id == null || name == null || slug == null) {
      throw ApiException(message: 'Missing required fields in Classroom data');
    }
    
    final createdAt = this.createdAt ?? DateTime.now();
    final updatedAt = this.updatedAt ?? DateTime.now();
    
    return Classroom(
      id: id!,
      name: name!,
      slug: slug!,
      lng: lng ?? '',
      lat: lat ?? '',
      mainImage: mainImage ?? '',
      annexesImages: annexesImages ?? const [],
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ClassroomDto.fromJson(Map<String, dynamic> json) => _$ClassroomDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ClassroomDtoToJson(this);
}
