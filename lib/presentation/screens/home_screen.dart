import 'package:campus_wa/presentation/widgets/university_card.dart';
import 'package:flutter/material.dart';
import 'package:campus_wa/data/mock_data.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_wa/presentation/widgets/search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filtered = universities.where((u) =>
        u.nom.toLowerCase().contains(searchQuery.toLowerCase()) ||
        u.slug.toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Universités")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBarWidget(
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final univ = filtered[index];
                return UniversityCard(
                  university: univ,
                  onTap: () => context.push('/universities/${univ.id}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}