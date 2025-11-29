import 'dart:io';

import 'package:campus_wa/core/exceptions/api_exception.dart';
import 'package:campus_wa/data/models/api/news_dto.dart';
import 'package:campus_wa/data/services/api_service.dart';
import 'package:campus_wa/domain/local/news_local_datasource.dart';
import 'package:campus_wa/domain/models/news.dart';
import 'package:campus_wa/domain/repositories/news_repository.dart';
import 'package:dio/dio.dart';

class NewsRepositoryImpl implements NewsRepository {
  NewsRepositoryImpl({
    required ApiService apiService,
    required NewsLocalDatasource newsLocal,
  }) : _apiService = apiService,
       _newsLocalDatasource = newsLocal;

  final ApiService _apiService;
  final NewsLocalDatasource _newsLocalDatasource;

  bool _isNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.error is SocketException;
  }

  @override
  Future<List<News>?> getNews(String? query) async {
    try {
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
        await _newsLocalDatasource.cacheNews(dtos);
        return domainList;
      }
    } catch (e) {
      if (e is DioException) {
        if (_isNetworkError(e)) {
          final news = await _newsLocalDatasource.getCachedNews();
          if (news != null) {
            return news.map((e) => e.toDomain()).toList();
          }
        }
      }
    }
    return null;
  }

  @override
  Future<News> createNews(News news, List<File?>? files) async {
    try {
      // Prepare the form data map
      final Map<String, dynamic> formDataMap = {
        'title': news.title,
        'content': news.content,
        // Convert boolean to integer (0 or 1) for FormData compatibility
        'is_published': (news.isPublished ?? true) ? 1 : 0,
        'published_at':
            news.publishedAt?.toIso8601String() ??
            DateTime.now().toIso8601String(),
      };

      // Only add files if there are actual files to upload
      if (files != null && files.isNotEmpty) {
        final filesList = <MultipartFile>[];
        for (final file in files) {
          if (file != null) {
            filesList.add(
              await MultipartFile.fromFile(
                file.path,
                filename: file.path.split('/').last,
              ),
            );
          }
        }
        if (filesList.isNotEmpty) {
          formDataMap['files'] = filesList;
        }
      }

      final formData = FormData.fromMap(formDataMap);

      // Send with proper headers for multipart/form-data
      final response = await _apiService.post(
        '/news',
        data: formData,
        headers: {'Content-Type': 'multipart/form-data'},
      );

      if (response.data is Map<String, dynamic>) {
        await _newsLocalDatasource.cacheNewsById(
          response.data['id'],
          NewsDto.fromJson(response.data),
        );
        return NewsDto.fromJson(response.data).toDomain();
      }
      throw Exception('Format de réponse inattendu');
    } on DioException catch (e) {
      throw ApiException(
        message: 'Erreur lors de la création: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
