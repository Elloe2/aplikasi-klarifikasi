import 'package:flutter/material.dart';
import '../models/search_result.dart';
import '../theme/app_theme.dart';

class SearchResultCard extends StatelessWidget {
  const SearchResultCard({
    super.key,
    required this.result,
    required this.onOpen,
    required this.onCopy,
    this.onSave,
    this.showSaveButton = true,
  });

  final SearchResult result;
  final ValueChanged<String> onOpen;
  final ValueChanged<String> onCopy;
  final VoidCallback? onSave;
  final bool showSaveButton;

  String _formatSocialMediaLink(String displayLink) {
    final lowerLink = displayLink.toLowerCase();

    if (lowerLink.contains('instagram.com')) {
      return 'Postingan di Instagram';
    } else if (lowerLink.contains('facebook.com') ||
        lowerLink.contains('fb.com')) {
      return 'Postingan di Facebook';
    } else if (lowerLink.contains('twitter.com') ||
        lowerLink.contains('x.com')) {
      return 'Postingan di X';
    } else if (lowerLink.contains('youtube.com') ||
        lowerLink.contains('youtu.be')) {
      return 'Postingan di YouTube';
    } else if (lowerLink.contains('reddit.com')) {
      return 'Postingan di Reddit';
    } else if (lowerLink.contains('tiktok.com')) {
      return 'Postingan di TikTok';
    } else if (lowerLink.contains('linkedin.com')) {
      return 'Postingan di LinkedIn';
    } else if (lowerLink.contains('threads.net')) {
      return 'Postingan di Threads';
    }

    return displayLink;
  }

  String _getRelativeTime(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.05),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (result.thumbnail != null && result.thumbnail!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      result.thumbnail!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox.shrink();
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.image,
                            color: Colors.white38,
                            size: 24,
                          ),
                        );
                      },
                    ),
                  ),

                if (result.thumbnail != null && result.thumbnail!.isNotEmpty)
                  const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFECE3),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.public,
                                    size: 16,
                                    color: Color(0xFF4A70A9),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      _formatSocialMediaLink(
                                        result.displayLink,
                                      ),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: const Color(0xFF4A70A9),
                                            fontWeight: FontWeight.w600,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (_getRelativeTime(result.publishedDate).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8, top: 4),
                          child: Text(
                            _getRelativeTime(result.publishedDate),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),

                      const SizedBox(height: 12),

                      Text(
                        result.snippet,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.72),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: result.link.isEmpty
                      ? null
                      : () => onOpen(result.link),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    minimumSize: const Size(120, 44),
                  ),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('Buka sumber'),
                ),

                OutlinedButton.icon(
                  onPressed: result.link.isEmpty
                      ? null
                      : () => onCopy(result.link),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    minimumSize: const Size(120, 44),
                  ),
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Salin tautan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
