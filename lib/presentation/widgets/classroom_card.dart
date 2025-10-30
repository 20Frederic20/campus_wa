import 'package:flutter/material.dart';
import 'package:campus_wa/domain/models/classroom.dart';

class ClassroomCard extends StatelessWidget {
  final Classroom classroom;
  final VoidCallback onTap;

  const ClassroomCard({super.key, required this.classroom, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        title: Text(classroom.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(classroom.slug),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}