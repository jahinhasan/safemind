import 'package:flutter/material.dart';

import '../models/comment_item.dart';
import '../theme/app_theme.dart';

class CommentCard extends StatelessWidget {
  const CommentCard({super.key, required this.comment, this.onMarkBest});

  final SafeMindComment comment;
  final VoidCallback? onMarkBest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: comment.highlighted ? AppColors.secondary : AppColors.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (comment.highlighted)
            Positioned(
              top: -30,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 14, color: Colors.white),
                    SizedBox(width: 6),
                    Text('Best Solution', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: comment.authorRole == 'advisor'
                      ? const LinearGradient(colors: [Color(0xFF9B7E5C), AppColors.primary])
                      : const LinearGradient(colors: [Color(0xFFC8B5A0), AppColors.primary]),
                ),
                child: Center(child: Text(comment.authorName.isEmpty ? 'A' : comment.authorName[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(child: Text(comment.authorName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
                        if (comment.authorRole == 'advisor') ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.warm, borderRadius: BorderRadius.circular(999)),
                            child: const Text('Advisor', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9B7E5C))),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(comment.content, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.text, height: 1.5)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: onMarkBest,
                          style: TextButton.styleFrom(foregroundColor: AppColors.secondary, padding: EdgeInsets.zero),
                          icon: const Icon(Icons.star_outline, size: 16),
                          label: const Text('Best'),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () {},
                          style: TextButton.styleFrom(foregroundColor: AppColors.muted, padding: EdgeInsets.zero),
                          icon: const Icon(Icons.favorite_outline, size: 16),
                          label: Text(comment.likes.toString()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}