import 'dart:convert';

import 'package:campus_wa/core/exceptions/cache_exception.dart';
import 'package:campus_wa/data/models/api/classroom_dto.dart';
import 'package:campus_wa/domain/local/classroom_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClassroomLocalDataSourceImpl implements ClassroomLocalDataSource {
  static const String _key = 'cached_classrooms';

  @override
  Future<void> cacheClassrooms(List<ClassroomDto> classrooms) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = classrooms.map((c) => c.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  @override
  Future<List<ClassroomDto>?> getCachedClassrooms() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return null;
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => ClassroomDto.fromJson(json)).toList();
  }

  @override
  Future<void> cacheClassroomsByUniversityId(
    String universityId,
    List<ClassroomDto> classrooms,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = classrooms.map((c) => c.toJson()).toList();
    final cacheKey = '$_key$universityId';
    await prefs.setString(cacheKey, jsonEncode(jsonList));
  }

  @override
  Future<List<ClassroomDto>?> getCachedClassroomsByUniversityId(
    String universityId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_key$universityId';
      final jsonString = prefs.getString(cacheKey);

      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>?;
      if (jsonList == null || jsonList.isEmpty) {
        return null;
      }

      return jsonList
          .map((json) => ClassroomDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException(
        'Échec de lecture du cache des salles pour l\'université $universityId: $e',
      );
    }
  }

  @override
  Future<void> cacheClassroomById(String id, ClassroomDto classroom) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = classroom.toJson();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  @override
  Future<ClassroomDto?> getCachedClassroomById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return null;
    final jsonList = jsonDecode(jsonString) as Map<String, dynamic>;
    return ClassroomDto.fromJson(jsonList);
  }

  @override
  Future<void> cacheClassroomsByIds(
    List<String> ids,
    List<ClassroomDto> classrooms,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = classrooms.map((c) => c.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  @override
  Future<List<ClassroomDto>?> getCachedClassroomsByIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return null;
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => ClassroomDto.fromJson(json)).toList();
  }

  @override
  Future<void> cacheRandomClassrooms(List<ClassroomDto> classrooms) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = classrooms.map((c) => c.toJson()).toList();
    await prefs.setString(
      '$_key'
      '_random',
      jsonEncode(jsonList),
    );
  }

  @override
  Future<List<ClassroomDto>?> getCachedRandomClassrooms() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(
      '$_key'
      '_random',
    );
    if (jsonString == null) return null;
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => ClassroomDto.fromJson(json)).toList();
  }

  @override
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
