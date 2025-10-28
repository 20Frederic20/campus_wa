import 'package:campus_wa/presentation/screens/not_found_screen.dart';
import 'package:campus_wa/presentation/screens/welcome_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/university_detail_screen.dart';
import '../screens/classroom_detail_screen.dart';

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
      ],
    ),
  ],
);

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isWelcomeScreen = GoRouterState.of(context).uri.path == '/';
    
    return Scaffold(
      body: child,
      bottomNavigationBar: isWelcomeScreen ? null : BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Recherche"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Favoris"),
        ],
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(context, index),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location == '/home') return 0;  // Onglet Accueil
    if (location == '/search') return 1; // Onglet Recherche
    if (location == '/favorites') return 2; // Onglet Favoris
    return 0; // Par défaut, premier onglet
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');  // Accueil
        break;
      case 1:
        context.go('/search'); // Recherche
        break;
      case 2:
        context.go('/favorites'); // Favoris
        break;
    }
  }
}