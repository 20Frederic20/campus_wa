import 'dart:io';

import 'package:campus_wa/domain/models/news.dart';

abstract class NewsRepository {
  Future<List<News>?> getNews(String? query);

  Future<News> createNews(News news, List<File?>? files);
}
