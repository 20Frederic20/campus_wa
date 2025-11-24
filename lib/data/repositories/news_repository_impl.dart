import 'dart:io';

import 'package:campus_wa/data/models/api/news_dto.dart';
import 'package:campus_wa/data/services/api_service.dart';
import 'package:campus_wa/domain/models/news.dart';
import 'package:campus_wa/domain/repositories/news_repository.dart';
import 'package:dio/dio.dart';

class NewsRepositoryImpl implements NewsRepository {
  NewsRepositoryImpl({required ApiService apiService})
    : _apiService = apiService;
  final ApiService _apiService;

  @override
  Future<List<News>?> getNews(String? query) async {
    final response = await _apiService.get(
      '/news',
      params: query != null ? {'search': query} : null,
    );
    if (response.data is Map<String, dynamic> &&
        response.data['news'] is List) {
      final List<dynamic> jsonList = response.data['news'] as List<dynamic>;
      final List<NewsDto> dtos = jsonList
          .map<NewsDto>(
            (dynamic j) => NewsDto.fromJson(j as Map<String, dynamic>),
          )
          .toList();
      final List<News> domainList = dtos
          .map<News>((NewsDto d) => d.toDomain())
          .toList();
      return domainList;
    }
    return null;
  }

  @override
  Future<News> createNews(News news, List<File?>? files) async {
    final formData = FormData.fromMap({
      'title': news.title,
      'content': news.content,
      'is_published': news.isPublished,
      'published_at': news.publishedAt?.toIso8601String(),
      'files': [
        for (final file in files ?? <File>[]) // add null check
          if (file != null) // add null check
            await MultipartFile.fromFile(
              file.path,
              filename: file.path?.split('/').last ?? '',
            ),
      ],
    });
    final response = await _apiService.post('/news', data: formData);
    return NewsDto.fromJson(response.data).toDomain();
  }
}
