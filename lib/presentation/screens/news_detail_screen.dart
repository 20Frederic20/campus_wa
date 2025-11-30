import 'package:cached_network_image/cached_network_image.dart';
import 'package:campus_wa/domain/models/news.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key, required this.news});

  final News news;

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(date);
  }

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareFile(String url) async {
    await Share.share(url);
  }

  void _openFullScreenImage(
    BuildContext context,
    String imageUrl, {
    String? heroTag,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: Hero(
              tag: heroTag ?? imageUrl,
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, __) =>
                      const CircularProgressIndicator(color: Colors.white),
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasFiles = news.filesUrls != null && news.filesUrls!.isNotEmpty;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: hasFiles
                  ? GestureDetector(
                      onTap: () => _openFullScreenImage(
                        context,
                        news.filesUrls!.first,
                        heroTag: 'news_${news.id}_detail',
                      ),
                      child: Hero(
                        tag: 'news_${news.id}_detail',
                        child: CachedNetworkImage(
                          imageUrl: news.filesUrls!.first,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[100],
                            child: Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.blue[400]!, Colors.blue[600]!],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.article_outlined,
                          size: 80,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    news.title ?? 'Sans titre',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(news.publishedAt),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Content
                  if (news.content != null && news.content!.isNotEmpty)
                    Text(
                      news.content!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[800],
                        height: 1.6,
                        fontSize: 16,
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Files section
                  if (hasFiles && news.filesUrls!.length > 1) ...[
                    Text(
                      'Fichiers joints',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...news.filesUrls!.skip(1).map((fileUrl) {
                      final isImage =
                          fileUrl.toLowerCase().endsWith('.jpg') ||
                          fileUrl.toLowerCase().endsWith('.jpeg') ||
                          fileUrl.toLowerCase().endsWith('.png') ||
                          fileUrl.toLowerCase().endsWith('.gif');

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Icon(
                            isImage ? Icons.image : Icons.insert_drive_file,
                            color: Colors.blue[600],
                          ),
                          title: Text(
                            fileUrl.split('/').last,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.share),
                                onPressed: () => _shareFile(fileUrl),
                              ),
                              IconButton(
                                icon: const Icon(Icons.open_in_new),
                                onPressed: () => _openFile(fileUrl),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final shareText = '${news.title}\n\n${news.content}';
          Share.share(shareText);
        },
        icon: const Icon(Icons.share),
        label: const Text('Partager'),
      ),
    );
  }
}
