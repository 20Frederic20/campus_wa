import 'package:campus_wa/core/theme/app_theme.dart';
import 'package:campus_wa/presentation/screens/add_classroom_screen.dart';
import 'package:campus_wa/presentation/screens/add_news_screen.dart';
import 'package:campus_wa/presentation/screens/add_university_screen.dart';
import 'package:campus_wa/presentation/screens/cgu_screen.dart';
import 'package:campus_wa/presentation/screens/edit_classroom_screen.dart';
import 'package:campus_wa/presentation/screens/help_center_screen.dart';
import 'package:campus_wa/presentation/screens/home_screen.dart';
import 'package:campus_wa/presentation/screens/news_screen.dart';
import 'package:campus_wa/presentation/screens/not_found_screen.dart';
import 'package:campus_wa/presentation/screens/privacy_policy_screen.dart';
import 'package:campus_wa/presentation/screens/settings_screen.dart';
import 'package:campus_wa/presentation/screens/under_development_screen.dart';
import 'package:campus_wa/presentation/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  errorBuilder: (context, state) => const NotFoundScreen(),
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/universities/add',
          builder: (context, state) => const AddUniversityScreen(),
        ),
        GoRoute(
          path: '/classrooms/add',
          builder: (context, state) => const AddClassroomScreen(),
        ),
        GoRoute(
          path: '/classrooms/:classroomId/edit',
          builder: (context, state) {
            final classroomId = state.pathParameters['classroomId']!;
            return EditClassroomScreen(classroomId: classroomId);
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
          builder: (context, state) =>
              const UnderDevelopmentScreen(featureName: 'Geolocation'),
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
          builder: (context, state) => const UnderDevelopmentScreen(
            featureName: 'Guide de prise en main',
          ),
        ),
        GoRoute(
          path: '/settings/help/advanced',
          builder: (context, state) => const UnderDevelopmentScreen(
            featureName: 'Fonctionnalités avancées',
          ),
        ),
        GoRoute(
          path: '/settings/privacy',
          builder: (context, state) => const PrivacyPolicyScreen(),
        ),
        GoRoute(path: '/news', builder: (context, state) => const NewsScreen()),
        GoRoute(
          path: '/news/add',
          builder: (context, state) => AddNewsScreen(),
        ),
        GoRoute(
          path: ':splat(.*)',
          builder: (context, state) => const NotFoundScreen(),
        ),
      ],
    ),
  ],
);

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
                  backgroundColor: AppColors.secondaryGreen,
                  indicatorColor: Colors.white.withOpacity(0.3),
                  surfaceTintColor: Colors.transparent,

                  labelBehavior:
                      NavigationDestinationLabelBehavior.onlyShowSelected,

                  labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      );
                    }
                    return const TextStyle(
                      fontSize: 12,
                      color: AppColors.white,
                    );
                  }),
                  selectedIndex: _calculateSelectedIndex(location),
                  onDestinationSelected: (index) =>
                      _onItemTapped(context, index),
                  destinations: [
                    const NavigationDestination(
                      icon: Icon(
                        Icons.home_outlined,
                        size: 22,
                        color: AppColors.white,
                      ),
                      selectedIcon: Icon(
                        Icons.home,
                        size: 22,
                        color: AppColors.white,
                        shadows: [
                          Shadow(blurRadius: 10.0, color: AppColors.white),
                        ],
                      ),
                      label: 'Accueil',
                    ),
                    const NavigationDestination(
                      icon: Icon(
                        Icons.speaker_notes_outlined,
                        size: 22,
                        color: AppColors.white,
                      ),
                      selectedIcon: Icon(
                        Icons.speaker_notes,
                        size: 22,
                        color: Colors.white,
                        shadows: [
                          Shadow(blurRadius: 10.0, color: Colors.white),
                        ],
                      ),
                      label: 'Flash Info',
                    ),
                    const NavigationDestination(
                      icon: Icon(
                        Icons.settings_outlined,
                        size: 22,
                        color: AppColors.white,
                      ),
                      selectedIcon: Icon(
                        Icons.settings,
                        size: 22,
                        color: Colors.white,
                        shadows: [
                          Shadow(blurRadius: 10.0, color: Colors.white),
                        ],
                      ),
                      label: 'Paramètres',
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  static int _calculateSelectedIndex(String location) {
    if (location == '/home' ||
        location.startsWith('/universities/') ||
        location == '/universities/add') {
      return 0;
    } else if (location.startsWith('/news')) {
      return 1;
    } else if (location.startsWith('/settings') ||
        location.startsWith('/settings/cgu')) {
      return 2;
    }
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/news');
        break;
      case 2:
        context.go('/settings');
        break;
    }
  }
}
