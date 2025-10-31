import 'package:campus_wa/domain/models/university.dart';
import 'package:flutter/material.dart';

class UniversityCard extends StatelessWidget {
  const UniversityCard({super.key, required this.university, required this.onTap});

  final University university;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        title: Text(university.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(university.slug),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}