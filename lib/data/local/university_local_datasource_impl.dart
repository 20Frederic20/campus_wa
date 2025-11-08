import 'dart:convert';

import 'package:campus_wa/data/models/api/university_dto.dart';
import 'package:campus_wa/domain/local/university_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UniversityLocalDataSourceImpl implements UniversityLocalDataSource {
  static const String _key = 'cached_universities';

  @override
  Future<void> cacheUniversities(List<UniversityDto> universities) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = universities.map((u) => u.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  @override
  Future<List<UniversityDto>?> getCachedUniversities() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return null;
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => UniversityDto.fromJson(json)).toList();
  }

  @override
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}