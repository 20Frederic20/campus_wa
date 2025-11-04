import 'package:campus_wa/core/injection.dart' as di;
import 'package:campus_wa/domain/repositories/university_repository.dart';
import 'package:flutter/material.dart';

class SearchBarAnchorWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  const SearchBarAnchorWidget({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SearchAnchor.bar(
      suggestionsBuilder: (context, controller) async {
        final universities = await di.getIt<UniversityRepository>().getUniversities();
        return universities!.map((university) => ListTile(
            title: Text(university.name),
            onTap: () {
              controller.text = university.name;
              onChanged(controller.text);
            },
          ));
      },
    );
  }
}