import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gap/gap.dart';
import 'package:campus_wa/domain/models/news.dart';

class NewsCard extends StatelessWidget {
  final News news;
  final bool isExpanded;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final VoidCallback? onBookmark;
  final ValueChanged<News?>? onNewsUpdated;

  const NewsCard({
    super.key,
    required this.news,
    this.isExpanded = false,
    this.onTap,
    this.onShare,
    this.onBookmark,
    this.onNewsUpdated,
  });

  void _openFullScreenImage(
    BuildContext context,
    String imageUrl, {
    String? heroTag,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.transparent),
          body: Center(
            child: Hero(
              tag: heroTag ?? imageUrl,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (_, __) => const CircularProgressIndicator(),
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.broken_image, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = news.filesUrls?.first;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: title + date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    news.title ?? '',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (news.publishedAt != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      news.publishedAt.toString(),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ),
              ],
            ),
            const Gap(8),

            // Image (si présente)
            if (imageUrl != null && imageUrl.isNotEmpty)
              GestureDetector(
                onTap: () => _openFullScreenImage(
                  context,
                  imageUrl,
                  heroTag: 'news_${news.id}_img',
                ),
                child: Hero(
                  tag: 'news_${news.id}_img',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: isExpanded ? 200 : 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: isExpanded ? 200 : 120,
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: isExpanded ? 200 : 120,
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
                  ),
                ),
              ),

            if (imageUrl != null && imageUrl.isNotEmpty) const Gap(8),

            // Excerpt / contenu
            if (isExpanded)
              Text(
                news.content ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 8,
                overflow: TextOverflow.ellipsis,
              )
            else
              Text(
                'lol',
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

            const Gap(12),

            // Actions row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // IconButton(
                    //   onPressed: onBookmark,
                    //   icon: Icon(
                    //     news.isBookmarked == true
                    //         ? Icons.bookmark
                    //         : Icons.bookmark_border,
                    //   ),
                    // ),
                    IconButton(
                      onPressed: onShare,
                      icon: const Icon(Icons.share_outlined),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () async {
                    final result = await Navigator.of(
                      context,
                    ).pushNamed('/news/${news.id}');
                    if (result is News) {
                      onNewsUpdated?.call(result);
                    } else {
                      onNewsUpdated?.call(null);
                    }
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: Text(isExpanded ? 'Voir' : 'Ouvrir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
