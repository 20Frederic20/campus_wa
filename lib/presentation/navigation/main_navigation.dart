import 'package:campus_wa/presentation/screens/add_classroom_screen.dart';
import 'package:campus_wa/presentation/screens/add_university_screen.dart';
import 'package:campus_wa/presentation/screens/classroom_detail_screen.dart';
import 'package:campus_wa/presentation/screens/home_screen.dart';
import 'package:campus_wa/presentation/screens/not_found_screen.dart';
import 'package:campus_wa/presentation/screens/under_development_screen.dart';
import 'package:campus_wa/presentation/screens/university_classrooms_screen.dart';
import 'package:campus_wa/presentation/screens/university_detail_screen.dart';
import 'package:campus_wa/presentation/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_wa/core/theme/app_theme.dart';

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
          path: '/universities/add',
          builder: (context, state) => const AddUniversityScreen(),
        ),
        GoRoute(
          path: '/universities/:id',
          builder: (context, state) {
            final universityId = state.pathParameters['id']!;
            return UniversityDetailScreen(
              universityId: universityId,
            );
          },
        ),
        GoRoute(
          path: '/classrooms/add',
          builder: (context, state) => const AddClassroomScreen(),
        ),
        GoRoute(
          path: '/classrooms/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ClassroomDetailScreen(
              classroomId: id,
            );
          },
        ),
        GoRoute(
          path: '/universities/:universityId/classrooms',
          builder: (context, state) {
            final universityId = state.pathParameters['universityId']!;
            final universityName = state.extra as String? ?? 'l\'université';
            return UniversityClassroomsScreen(
              universityId: universityId,
              universityName: universityName,
            );
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
          path: '/geolocation',
          builder: (context, state) => const UnderDevelopmentScreen(featureName: 'Geolocation'),
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
  const MainScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final isWelcomeScreen = location == '/';

    return Scaffold(
      body: child,
      bottomNavigationBar: isWelcomeScreen
          ? null
          : Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: NavigationBar(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  indicatorColor: AppColors.primaryGreen.withOpacity(0.2),
                  surfaceTintColor: Colors.transparent,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  selectedIndex: _calculateSelectedIndex(location),
                  onDestinationSelected: (index) => _onItemTapped(context, index),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined, size: 26),
                      selectedIcon: Icon(Icons.home, size: 26, color: AppColors.primaryGreen),
                      label: 'Accueil',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.search_outlined, size: 26),
                      selectedIcon: Icon(Icons.search, size: 26, color: AppColors.primaryGreen),
                      label: 'Recherche',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.star_outline, size: 26),
                      selectedIcon: Icon(Icons.star, size: 26, color: AppColors.primaryGreen),
                      label: 'Favoris',
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// Calcule quel onglet est sélectionné
  static int _calculateSelectedIndex(String location) {
    if (location == '/home' || 
        location.startsWith('/universities/') || 
        location == '/universities/add') return 0;
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
