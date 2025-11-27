import 'package:campus_wa/core/injection.dart' as di;
import 'package:campus_wa/core/theme/app_theme.dart';
import 'package:campus_wa/presentation/navigation/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("Fichier .env chargé avec succès.");
  } catch (e) {
    debugPrint("Erreur lors du chargement du fichier .env: $e");
    // Continue l'exécution même si le .env n'est pas chargé
  }
  await di.setupDependencies();
  runApp(const MyApp());
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
