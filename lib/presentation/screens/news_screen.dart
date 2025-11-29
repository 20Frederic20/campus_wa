import 'dart:developer';

import 'package:campus_wa/core/injection.dart' as di;
import 'package:campus_wa/domain/models/news.dart';
import 'package:campus_wa/domain/repositories/news_repository.dart';
import 'package:campus_wa/presentation/widgets/news_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<News> _news = [];

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    try {
      log('Starting to load news...');
      final news = await di.getIt<NewsRepository>().getNews();
      log('News loaded: ${news?.length ?? 0} items');
      if (news != null) {
        for (var i = 0; i < news.length; i++) {
          log('News $i: ${news[i].title}');
        }
      }
      if (!mounted) return;
      setState(() {
        _news = news ?? [];
      });
      log('State updated, _news.length = ${_news.length}');
    } catch (e) {
      log('Error loading news: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Actualités'), centerTitle: true),
      body: _news.isEmpty
          ? const Center(child: Text('Aucune actualité pour le moment'))
          : PageView.builder(
              scrollDirection: Axis.vertical,
              controller: PageController(viewportFraction: 0.7),
              itemCount: _news.length,
              itemBuilder: (context, index) {
                final news = _news[index];
                return NewsCard(
                  news: news,
                  onTap: () {
                    context.push('/news/${news.id}', extra: news);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/news/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
