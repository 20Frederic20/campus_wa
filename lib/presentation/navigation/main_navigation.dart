import 'package:campus_wa/core/theme/app_theme.dart';
import 'package:campus_wa/presentation/screens/add_classroom_screen.dart';
import 'package:campus_wa/presentation/screens/add_university_screen.dart';
import 'package:campus_wa/presentation/screens/cgu_screen.dart';
import 'package:campus_wa/presentation/screens/classroom_detail_screen.dart';
import 'package:campus_wa/presentation/screens/edit_classroom_screen.dart';
import 'package:campus_wa/presentation/screens/help_center_screen.dart';
import 'package:campus_wa/presentation/screens/home_screen.dart';
import 'package:campus_wa/presentation/screens/not_found_screen.dart';
import 'package:campus_wa/presentation/screens/privacy_policy_screen.dart';
import 'package:campus_wa/presentation/screens/settings_screen.dart';
import 'package:campus_wa/presentation/screens/under_development_screen.dart';
import 'package:campus_wa/presentation/screens/university_classrooms_screen.dart';
import 'package:campus_wa/presentation/screens/university_detail_screen.dart';
import 'package:campus_wa/presentation/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
          path: '/classrooms/:classroomId',
          builder: (context, state) {
            final id = state.pathParameters['classroomId']!;
            return ClassroomDetailScreen(
              classroomId: id,
            );
          },
        ),
        GoRoute(
          path: '/classrooms/:classroomId/edit',
          builder: (context, state) {
            final classroomId = state.pathParameters['classroomId']!;
            return EditClassroomScreen(
              classroomId: classroomId,
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
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/settings/cgu',
          builder: (context, state) => const CguScreen(),
        ),
        GoRoute(
          path: '/settings/help',
          builder: (context, state) => const HelpCenterScreen(),
        ),
        GoRoute(
          path: '/settings/help/guide',
          builder: (context, state) => const UnderDevelopmentScreen(featureName: 'Guide de prise en main'),
        ),
        GoRoute(
          path: '/settings/help/advanced',
          builder: (context, state) => const UnderDevelopmentScreen(featureName: 'Fonctionnalités avancées'),
        ),
        GoRoute(
          path: '/settings/privacy',
          builder: (context, state) => const PrivacyPolicyScreen(),
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
                    color: Colors.black.withValues(alpha: 0.1),
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
                  backgroundColor: AppColors.primaryGreen,
                  indicatorColor: Colors.white.withValues(alpha: 0.3),
                  surfaceTintColor: Colors.transparent,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.selected)) {
                        return const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Optional: set the selected text color
                        );
                      }
                      return const TextStyle(color: Colors.white70); // Unselected text style
                    },
                  ),
                  selectedIndex: _calculateSelectedIndex(location),
                  onDestinationSelected: (index) => _onItemTapped(context, index),
                  destinations: [
                    const NavigationDestination(
                      icon: Icon(
                        Icons.home_outlined, size: 26, color: AppColors.white),
                      selectedIcon: Icon(Icons.home, size: 28, color: Colors.white, shadows: [Shadow(blurRadius: 10.0, color: Colors.white)]),
                      label: 'Accueil',
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.calendar_today_outlined, size: 26, color: AppColors.white),
                      selectedIcon: Icon(Icons.calendar_today, size: 28, color: Colors.white, shadows: [Shadow(blurRadius: 10.0, color: Colors.white)]),
                      label: 'Plannings',
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.settings_outlined, size: 26, color: AppColors.white),
                      selectedIcon: Icon(Icons.settings, size: 28, color: Colors.white, shadows: [Shadow(blurRadius: 10.0, color: Colors.white)]),
                      label: 'Paramètres',
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// Calcule quel onglet est sélectionné
  static int _calculateSelectedIndex(String location) {
    if (location == '/home' ||  location.startsWith('/universities/') || location == '/universities/add') {
      return 0;
    }
    else if (location.startsWith('/plannings')) {
      return 1;
    }
    else if (location.startsWith('/settings') || location.startsWith('/settings/cgu')) {
      return 2;
    }
    return 0; // par défaut
  }

  /// Navigation entre les onglets
  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/plannings');
        break;
      case 2:
        context.go('/settings');
        break;
    }
  }
}
