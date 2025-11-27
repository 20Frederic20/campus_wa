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

  @JsonKey(name: 'is_published')
  final bool? isPublished;

  @JsonKey(name: 'published_at')
  final DateTime? publishedAt;

  @JsonKey(name: 'files_urls')
  final List<String>? filesUrls;

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
