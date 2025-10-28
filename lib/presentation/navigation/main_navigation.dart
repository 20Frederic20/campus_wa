import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_wa/presentation/screens/not_found_screen.dart';
import 'package:campus_wa/presentation/screens/welcome_screen.dart';
import '../screens/home_screen.dart';
import '../screens/university_detail_screen.dart';
import '../screens/classroom_detail_screen.dart';
import '../screens/under_development_screen.dart';

/// Configuration principale du router avec GoRouter
final GoRouter router = GoRouter(
  errorBuilder: (context, state) => const NotFoundScreen(),
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/universities/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return UniversityDetailScreen(universityId: id);
          },
        ),
        GoRoute(
          path: '/classrooms/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ClassroomDetailScreen(classroomId: id);
          },
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) =>
              const UnderDevelopmentScreen(featureName: 'Recherche'),
        ),
        GoRoute(
          path: '/favorites',
          builder: (context, state) =>
              const UnderDevelopmentScreen(featureName: 'Favoris'),
        ),
        GoRoute(
          path: ':splat(.*)',
          builder: (context, state) => const NotFoundScreen(),
        ),
      ],
    ),
  ],
);

/// Scaffold principal avec barre de navigation inférieure
class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final isWelcomeScreen = location == '/';

    return Scaffold(
      body: child,
      bottomNavigationBar: isWelcomeScreen
          ? null
          : BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "Accueil",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: "Recherche",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.star),
                  label: "Favoris",
                ),
              ],
              currentIndex: _calculateSelectedIndex(location),
              onTap: (index) => _onItemTapped(context, index),
            ),
    );
  }

  /// Calcule quel onglet est sélectionné
  static int _calculateSelectedIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/favorites')) return 2;
    return 0; // par défaut
  }

  /// Navigation entre les onglets
  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/favorites');
        break;
    }
  }
}
