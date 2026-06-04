import 'package:flutter/material.dart';

import '../models/post_item.dart';
import '../theme/app_theme.dart';
import 'section_card.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, required this.onTap, required this.onSupport, this.onAuthorTap});

  final SafeMindPost post;
  final VoidCallback onTap;
  final VoidCallback onSupport;
  final VoidCallback? onAuthorTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: onAuthorTap,
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [AppColors.secondary, AppColors.primary]),
                          ),
                          child: Center(
                            child: Text(
                              post.authorName.isEmpty ? 'A' : post.authorName[0],
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      post.authorName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  if (post.authorMood != null) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      ['😢', '😞', '😐', '🙂', '😄'][post.authorMood! - 1],
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                _formatAge(post.createdAt),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.softGreen, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      post.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(post.content, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.text, height: 1.6)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Wrap(
                  spacing: 22,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _Stat(icon: Icons.favorite_outline, value: post.supportCount.toString()),
                    _Stat(icon: Icons.message_outlined, value: post.commentCount.toString()),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (post.hasAdvisorResponse)
                      _StatusChip(label: 'Advisor', background: AppColors.warm, foreground: const Color(0xFF9B7E5C), icon: Icons.verified),
                    if (post.solved)
                      _StatusChip(label: 'Solved', background: AppColors.softGreen, foreground: AppColors.secondary, icon: Icons.check_circle),
                  ],
                ),
                TextButton.icon(
                  onPressed: onSupport,
                  icon: const Icon(Icons.thumb_up_outlined, size: 16),
                  label: const Text('Support'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatAge(DateTime createdAt) {
    final age = DateTime.now().difference(createdAt);
    if (age.inMinutes < 60) return '${age.inMinutes} min ago';
    if (age.inHours < 24) return '${age.inHours} hours ago';
    return '${age.inDays} days ago';
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.muted),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.background, required this.foreground, required this.icon});

  final String label;
  final Color background;
  final Color foreground;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: foreground, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}