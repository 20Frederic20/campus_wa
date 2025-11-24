import 'package:campus_wa/core/injection.dart' as di;
import 'package:campus_wa/domain/models/news.dart';
import 'package:campus_wa/domain/repositories/news_repository.dart';
import 'package:flutter/material.dart';

class AddNewsScreen extends StatefulWidget {
  @override
  _AddNewsScreenState createState() => _AddNewsScreenState();
}

class _AddNewsScreenState extends State<AddNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une actualité'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Titre'),
                controller: _titleController,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Contenu'),
                controller: _contentController,
                maxLines: null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  final title = _titleController.text;
                  final content = _contentController.text;
                  final news = News(id: '', title: title, content: content);
                  final newsRepository = di.getIt<NewsRepository>();
                  try {
                    await newsRepository.createNews(news, null);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Actualité ajoutée')),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Erreur lors de l\'ajout de l\'actualité: $e',
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Ajouter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
