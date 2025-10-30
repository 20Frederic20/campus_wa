import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_wa/data/mock_data.dart';

class UniversityClassroomsScreen extends StatelessWidget {
  final String universityId;

  const UniversityClassroomsScreen({super.key, required this.universityId});

  @override
  Widget build(BuildContext context) {
    final univ = universities.firstWhere((u) => u.id == universityId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Amphithéâtres de ${univ.name}'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: univ.classrooms?.length,
        itemBuilder: (context, index) {
          final classroom = univ.classrooms?[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.meeting_room, color: Colors.red),
                title: Text(
                  classroom?.nom ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(classroom?.slug ?? ''),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/classrooms/${classroom?.id}'),
              ),
            ),
          );
        },
      ),
    );
  }
}