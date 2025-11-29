import 'dart:convert';

import 'package:campus_wa/data/models/api/university_dto.dart';
import 'package:campus_wa/domain/local/university_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UniversityLocalDataSourceImpl implements UniversityLocalDataSource {
  static const String _key = 'cached_universities';

  // Cache en mémoire pour éviter les lectures répétées
  List<UniversityDto>? _memoryCache;

  // Instance réutilisable de SharedPreferences
  SharedPreferences? _prefs;

  // Méthode helper pour obtenir SharedPreferences (singleton pattern)
  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Méthode helper pour charger la liste depuis le cache
  Future<List<UniversityDto>> _loadFromStorage() async {
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
    _memoryCache = jsonList
        .map((json) => UniversityDto.fromJson(json))
        .toList();
    return _memoryCache!;
  }

  // Méthode helper pour sauvegarder la liste
  Future<void> _saveToStorage(List<UniversityDto> universities) async {
    _memoryCache = universities; // Mettre à jour le cache mémoire
    final prefs = await _getPrefs();
    final jsonList = universities.map((u) => u.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  @override
  Future<void> cacheUniversities(List<UniversityDto> universities) async {
    await _saveToStorage(universities);
  }

  @override
  Future<List<UniversityDto>?> getCachedUniversities() async {
    final universities = await _loadFromStorage();
    return universities.isEmpty ? null : universities;
  }

  @override
  Future<void> clearCache() async {
    _memoryCache = null; // Vider le cache mémoire
    final prefs = await _getPrefs();
    await prefs.remove(_key);
  }
}
