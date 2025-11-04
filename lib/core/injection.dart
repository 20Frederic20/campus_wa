import 'package:campus_wa/data/local/classroom_local_datasource_impl.dart';
import 'package:campus_wa/data/local/university_local_datasource_impl.dart';
import 'package:campus_wa/data/repositories/claassroom_repository_impl.dart';
import 'package:campus_wa/data/repositories/university_repository_impl.dart';
import 'package:campus_wa/data/services/api_service.dart';
import 'package:campus_wa/domain/local/classroom_local_datasource.dart';
import 'package:campus_wa/domain/local/university_local_datasource.dart';
import 'package:campus_wa/domain/repositories/classroom_repository.dart';
import 'package:campus_wa/domain/repositories/university_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Configuration de Dio avec des options de base
  final dio = Dio(BaseOptions(
    baseUrl: dotenv.get('API_BASE_URL', fallback: 'http://localhost:3000'),
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Enregistrement des dépendances
  getIt
    ..registerSingleton<Dio>(dio)
    ..registerSingleton<ApiService>(ApiService())
    ..registerLazySingleton<UniversityLocalDataSource>(() => UniversityLocalDataSourceImpl())
    ..registerLazySingleton<ClassroomLocalDataSource>(() => ClassroomLocalDataSourceImpl())
    ..registerLazySingleton<UniversityRepository>(
      () => UniversityRepositoryImpl(
        apiService: getIt<ApiService>(), 
        universityLocal: getIt<UniversityLocalDataSource>(),
        classroomLocal: getIt<ClassroomLocalDataSource>()
      ),
    )
    ..registerLazySingleton<ClassroomRepository>(
      () => ClassroomRepositoryImpl(apiService: getIt<ApiService>()),
    );
}