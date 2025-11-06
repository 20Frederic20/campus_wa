import 'package:campus_wa/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de l'application
            Image.asset('assets/img/logo.jpg', width: 150, height: 150),
            const SizedBox(height: 40),
            // Titre
            const Text(
              'Bienvenue sur Campus WA',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 60),
            // Bouton continuer
            ElevatedButton(
              onPressed: () {
                // Navigation vers l'écran d'accueil
                context.go('/home');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                backgroundColor: AppColors.primaryGreen, // Couleur par défaut
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
                shadowColor: Colors.black.withValues(alpha: 0.2),
                animationDuration: const Duration(
                  milliseconds: 200,
                ), // Animation plus fluide
              ),
              child: const Text(
                'Continuer',
                style: TextStyle(fontSize: 18, color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
