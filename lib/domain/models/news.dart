import 'package:equatable/equatable.dart';

class News extends Equatable {
  const News({
    required this.id,
    required this.title,
    this.publishedAt,
    this.isPublished,
    this.content,
    this.filesUrls = const [],
  });

  final String id;
  final String title;
  final String? content;
  final bool? isPublished;
  final DateTime? publishedAt;
  final List<String>? filesUrls;

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    isPublished,
    publishedAt,
    filesUrls,
  ];
}
