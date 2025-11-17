import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Actualités'), centerTitle: true),
      body: const Center(child: Text('Aucune actualité pour le moment')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/news/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
