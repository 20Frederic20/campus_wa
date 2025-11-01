import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Couleurs principales du logo
  static const Color primaryGreen = Color(0xFF2E7D32); // Vert foncé
  static const Color secondaryGreen = Color(0xFF4CAF50); // Vert plus clair
  static const Color accentYellow = Color(0xFFFFC107); // Jaune
  static const Color accentRed = Color(0xFFE53935); // Rouge
  static const Color white = Color(0xFFFFFFFF); // Blanc
  
  // Couleurs de texte
  static const Color textPrimary = Color(0xFF212121); // Noir pour le texte principal
  static const Color textSecondary = Color(0xFF757575); // Gris pour le texte secondaire
  
  // Couleurs d'arrière-plan
  static const Color backgroundLight = Color(0xFFF5F5F5); // Gris très clair pour les arrière-plans
  static const Color surfaceLight = Color(0xFFFFFFFF); // Blanc pour les surfaces
  
  // Couleurs de bordure
  static const Color borderLight = Color(0xFFE0E0E0); // Gris clair pour les bordures
}

class AppTheme {
  static final theme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
    ),
  );
}