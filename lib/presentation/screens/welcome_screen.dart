import 'package:campus_wa/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/img/welcome-background.png', fit: BoxFit.cover),

          Container(color: AppColors.primaryGreen.withOpacity(0.6)),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/img/logo.jpg', width: 150, height: 150),
                const SizedBox(height: 40),
                const Text(
                  'Bienvenue sur Campus WA',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 60),
                ElevatedButton(
                  onPressed: () {
                    context.go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                    shadowColor: Colors.black.withOpacity(0.2),
                    animationDuration: const Duration(milliseconds: 200),
                  ),
                  child: const Text(
                    'Continuer',
                    style: TextStyle(fontSize: 18, color: AppColors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
