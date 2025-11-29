import 'dart:convert';

import 'package:campus_wa/core/exceptions/cache_exception.dart';
import 'package:campus_wa/data/models/api/classroom_dto.dart';
import 'package:campus_wa/domain/local/classroom_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClassroomLocalDataSourceImpl implements ClassroomLocalDataSource {
  static const String _key = 'cached_classrooms';

  // Cache en mémoire unifié pour toutes les classrooms
  List<ClassroomDto>? _memoryCache;
  final Map<String, List<ClassroomDto>> _universityCache = {};

  // Instance réutilisable de SharedPreferences
  SharedPreferences? _prefs;

  // Méthode helper pour obtenir SharedPreferences (singleton pattern)
  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Méthode helper pour charger la liste principale depuis le cache
  Future<List<ClassroomDto>> _loadFromStorage() async {
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
    _memoryCache = jsonList.map((json) => ClassroomDto.fromJson(json)).toList();
    return _memoryCache!;
  }

  // Méthode helper pour sauvegarder la liste principale
  Future<void> _saveToStorage(List<ClassroomDto> classrooms) async {
    _memoryCache = classrooms;
    final prefs = await _getPrefs();
    final jsonList = classrooms.map((c) => c.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  @override
  Future<void> cacheClassrooms(List<ClassroomDto> classrooms) async {
    await _saveToStorage(classrooms);
  }

  @override
  Future<List<ClassroomDto>?> getCachedClassrooms() async {
    final classrooms = await _loadFromStorage();
    return classrooms.isEmpty ? null : classrooms;
  }

  @override
  Future<void> cacheClassroomsByUniversityId(
    String universityId,
    List<ClassroomDto> classrooms,
  ) async {
    // Mettre à jour le cache mémoire
    _universityCache[universityId] = classrooms;

    // Sauvegarder sur le disque
    final prefs = await _getPrefs();
    final jsonList = classrooms.map((c) => c.toJson()).toList();
    final cacheKey = '${_key}_university_$universityId';
    await prefs.setString(cacheKey, jsonEncode(jsonList));
  }

  @override
  Future<List<ClassroomDto>?> getCachedClassroomsByUniversityId(
    String universityId,
  ) async {
    try {
      // Vérifier d'abord le cache mémoire
      if (_universityCache.containsKey(universityId)) {
        return _universityCache[universityId];
      }

      // Sinon, charger depuis le disque
      final prefs = await _getPrefs();
      final cacheKey = '${_key}_university_$universityId';
      final jsonString = prefs.getString(cacheKey);

      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>?;
      if (jsonList == null || jsonList.isEmpty) {
        return null;
      }

      final classrooms = jsonList
          .map((json) => ClassroomDto.fromJson(json as Map<String, dynamic>))
          .toList();

      // Mettre en cache mémoire
      _universityCache[universityId] = classrooms;

      return classrooms;
    } catch (e) {
      throw CacheException(
        'Échec de lecture du cache des salles pour l\'université $universityId: $e',
      );
    }
  }

  @override
  Future<void> cacheClassroomById(String id, ClassroomDto classroom) async {
    final classrooms = await _loadFromStorage();

    // Chercher si la classroom existe déjà
    final existingIndex = classrooms.indexWhere((c) => c.id == id);

    if (existingIndex != -1) {
      // Mettre à jour la classroom existante
      classrooms[existingIndex] = classroom;
    } else {
      // Ajouter la nouvelle classroom au début de la liste
      classrooms.insert(0, classroom);
    }

    // Sauvegarder la liste mise à jour
    await _saveToStorage(classrooms);
  }

  @override
  Future<ClassroomDto?> getCachedClassroomById(String id) async {
    final classrooms = await _loadFromStorage();

    // Chercher la classroom par ID dans la liste
    try {
      return classrooms.firstWhere((classroom) => classroom.id == id);
    } catch (e) {
      // Si la classroom n'est pas trouvée
      return null;
    }
  }

  @override
  Future<void> cacheClassroomsByIds(
    List<String> ids,
    List<ClassroomDto> classrooms,
  ) async {
    final allClassrooms = await _loadFromStorage();

    // Ajouter ou mettre à jour chaque classroom
    for (final classroom in classrooms) {
      final existingIndex = allClassrooms.indexWhere(
        (c) => c.id == classroom.id,
      );

      if (existingIndex != -1) {
        allClassrooms[existingIndex] = classroom;
      } else {
        allClassrooms.insert(0, classroom);
      }
    }

    await _saveToStorage(allClassrooms);
  }

  @override
  Future<List<ClassroomDto>?> getCachedClassroomsByIds(List<String> ids) async {
    final classrooms = await _loadFromStorage();

    // Filtrer les classrooms par IDs
    final filteredClassrooms = classrooms
        .where((classroom) => ids.contains(classroom.id))
        .toList();

    return filteredClassrooms.isEmpty ? null : filteredClassrooms;
  }

  @override
  Future<void> cacheRandomClassrooms(List<ClassroomDto> classrooms) async {
    final allClassrooms = await _loadFromStorage();

    // Fusionner les classrooms random avec la liste principale
    for (final classroom in classrooms) {
      final existingIndex = allClassrooms.indexWhere(
        (c) => c.id == classroom.id,
      );

      if (existingIndex != -1) {
        // Mettre à jour si elle existe déjà
        allClassrooms[existingIndex] = classroom;
      } else {
        // Ajouter si nouvelle
        allClassrooms.add(classroom);
      }
    }

    // Sauvegarder la liste fusionnée
    await _saveToStorage(allClassrooms);
  }

  @override
  Future<List<ClassroomDto>?> getCachedRandomClassrooms() async {
    // Retourner depuis le cache unifié
    final classrooms = await _loadFromStorage();
    return classrooms.isEmpty ? null : classrooms;
  }

  @override
  Future<void> clearCache() async {
    // Vider tous les caches mémoire
    _memoryCache = null;
    _universityCache.clear();

    // Vider le cache disque
    final prefs = await _getPrefs();

    // Supprimer toutes les clés liées aux classrooms
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_key)) {
        await prefs.remove(key);
      }
    }
  }
}
