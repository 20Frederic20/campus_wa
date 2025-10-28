import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/university_detail_screen.dart';
import '../screens/classroom_detail_screen.dart';

final GoRouter router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/',
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
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
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
    if (location.startsWith('/universities') || location.startsWith('/classrooms')) return 0;
    if (location == '/search') return 1;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index == 0) context.go('/');
    if (index == 1) context.go('/search'); // À implémenter
    if (index == 2) context.go('/favorites'); // V2
  }
}