import 'dart:convert';

import 'package:campus_wa/data/models/api/news_dto.dart';
import 'package:campus_wa/domain/local/news_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewsLocalDatasourceImpl implements NewsLocalDatasource {
  static const String _key = 'cached_news';

  // Cache en mémoire pour éviter les lectures répétées
  List<NewsDto>? _memoryCache;

  // Instance réutilisable de SharedPreferences
  SharedPreferences? _prefs;

  // Méthode helper pour obtenir SharedPreferences (singleton pattern)
  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Méthode helper pour charger la liste depuis le cache
  Future<List<NewsDto>> _loadFromStorage() async {
    // Si déjà en mémoire, retourner directement
    if (_memoryCache != null) {
      return _memoryCache!;
    }

    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) {
      _memoryCache = [];
      return [];
    }

    final jsonList = jsonDecode(jsonString) as List;
    _memoryCache = jsonList.map((json) => NewsDto.fromJson(json)).toList();
    return _memoryCache!;
  }

  // Méthode helper pour sauvegarder la liste
  Future<void> _saveToStorage(List<NewsDto> newsList) async {
    _memoryCache = newsList; // Mettre à jour le cache mémoire
    final prefs = await _getPrefs();
    final jsonList = newsList.map((n) => n.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  @override
  Future<List<NewsDto>?> getCachedNews() async {
    final newsList = await _loadFromStorage();
    return newsList.isEmpty ? null : newsList;
  }

  @override
  Future<void> cacheNews(List<NewsDto> news) async {
    await _saveToStorage(news);
  }

  @override
  Future<void> cacheNewsById(String id, NewsDto news) async {
    final newsList = await _loadFromStorage();

    // Chercher si la news existe déjà
    final existingIndex = newsList.indexWhere((n) => n.id == id);

    if (existingIndex != -1) {
      // Mettre à jour la news existante
      newsList[existingIndex] = news;
    } else {
      // Ajouter la nouvelle news au début de la liste
      newsList.insert(0, news);
    }

    // Sauvegarder la liste mise à jour
    await _saveToStorage(newsList);
  }

  @override
  Future<NewsDto?> getCachedNewsById(String id) async {
    final newsList = await _loadFromStorage();

    // Chercher la news par ID dans la liste
    try {
      return newsList.firstWhere((news) => news.id == id);
    } catch (e) {
      // Si la news n'est pas trouvée
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    _memoryCache = null; // Vider le cache mémoire
    final prefs = await _getPrefs();
    await prefs.remove(_key);
  }
}
