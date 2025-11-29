import 'package:campus_wa/data/models/api/news_dto.dart';

abstract class NewsLocalDatasource {
  Future<List<NewsDto>?> getCachedNews();
  Future<void> cacheNews(List<NewsDto> news);
  Future<void> cacheNewsById(String id, NewsDto news);
  Future<NewsDto?> getCachedNewsById(String id);
  Future<void> clearCache();
}
