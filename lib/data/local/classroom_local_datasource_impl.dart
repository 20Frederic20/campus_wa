import 'dart:convert';
import 'package:campus_wa/domain/local/classroom_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api/classroom_dto.dart';

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
  Future<void> cacheClassroomsByUniversityId(String universityId, List<ClassroomDto> classrooms) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = classrooms.map((c) => c.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  @override
  Future<List<ClassroomDto>?> getCachedClassroomsByUniversityId(String universityId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return null;
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => ClassroomDto.fromJson(json)).toList();
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}