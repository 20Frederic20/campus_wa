import 'package:campus_wa/domain/models/news.dart';
import 'package:json_annotation/json_annotation.dart';

part 'news_dto.g.dart';

@JsonSerializable()
class NewsDto {
  const NewsDto({
    required this.id,
    required this.title,
    this.content,
    this.isPublished,
    this.publishedAt,
    this.filesUrls,
  });

  factory NewsDto.fromJson(Map<String, dynamic> json) =>
      _$NewsDtoFromJson(json);

  factory NewsDto.create({
    required String id,
    required String title,
    String? content,
    bool? isPublished,
    DateTime? publishedAt,
    List<String>? filesUrls,
  }) {
    return NewsDto(
      id: id,
      title: title,
      content: content,
      isPublished: isPublished,
      publishedAt: publishedAt,
      filesUrls: filesUrls,
    );
  }
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'content')
  final String? content;

  @JsonKey(name: 'is_published', fromJson: _intToBool, toJson: _boolToInt)
  final bool? isPublished;

  @JsonKey(name: 'published_at')
  final DateTime? publishedAt;

  @JsonKey(name: 'files')
  final List<String>? filesUrls;

  static bool? _intToBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return null;
  }

  static int? _boolToInt(bool? value) {
    if (value == null) return null;
    return value ? 1 : 0;
  }

  Map<String, dynamic> toJson() => _$NewsDtoToJson(this);

  News toDomain() => News(
    id: id,
    title: title,
    content: content,
    isPublished: isPublished,
    publishedAt: publishedAt,
    filesUrls: filesUrls,
  );
}
