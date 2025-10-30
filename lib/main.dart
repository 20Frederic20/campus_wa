import 'package:campus_wa/data/repositories/university_repository_impl.dart';
import 'package:campus_wa/domain/repositories/university_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'presentation/navigation/main_navigation.dart';
import 'package:get_it/get_it.dart';
import 'package:campus_wa/data/services/api_service.dart';
import 'package:dio/dio.dart';

final getIt = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("Fichier .env chargé avec succès.");
  } catch (e) {
    debugPrint("Erreur lors du chargement du fichier .env: $e");
    // Continue l'exécution même si le .env n'est pas chargé
  }
  await setupDependencies();
  runApp(const MyApp());
}

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
    ..registerLazySingleton<UniversityRepository>(
      () => UniversityRepositoryImpl(apiService: getIt<ApiService>()),
    );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Universités',
      theme: AppTheme.theme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}