import 'dart:developer';

import 'package:campus_wa/core/injection.dart' as di;
import 'package:campus_wa/data/services/search_service.dart';
import 'package:flutter/material.dart';

class SearchBarAnchorWidget extends StatelessWidget {
  const SearchBarAnchorWidget({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) {
    return SearchAnchor.bar(
      suggestionsBuilder: (context, controller) async {
        if (controller.text.isEmpty) {
          return [];
        }

        try {
          final searchService = di.getIt<SearchService>();
          final results = await searchService.search(controller.text);
          log(results.toString());
          if (results.isEmpty) {
            return [const ListTile(title: Text('Aucun résultat'))];
          }

          return results.map((result) {
            return ListTile(
              leading: Icon(
                result.type == 'university' ? Icons.school : Icons.meeting_room,
              ),
              title: Text(result.name),
              subtitle: Text(
                result.type == 'university' ? 'Université' : 'Salle de classe',
              ),
              onTap: () {
                controller.text = result.name;
                onChanged.call(result);
                controller.closeView('');
              },
            );
          }).toList();
        } catch (e) {
          return [
            ListTile(
              title: const Text('Erreur lors de la recherche'),
              subtitle: Text('$e'),
            ),
          ];
        }
      },
    );
  }
}
