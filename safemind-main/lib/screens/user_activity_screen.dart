import 'package:flutter/material.dart';

import '../models/comment_item.dart';
import '../models/post_item.dart';
import '../services/backend_service.dart';
import '../theme/app_theme.dart';
import '../widgets/comment_card.dart';
import '../widgets/post_card.dart';
import '../widgets/section_card.dart';
import 'post_details_screen.dart';

class UserActivityScreen extends StatelessWidget {
  const UserActivityScreen({
    super.key,
    required this.userId,
    required this.userName,
    this.isAnonymous = false,
  });

  final String userId;
  final String userName;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userName),
      ),
      body: StreamBuilder<List<SafeMindPost>>(
        stream: SafeMindBackend.instance.watchPostsByAuthor(userId),
        builder: (context, postsSnapshot) {
          final posts = postsSnapshot.data ?? const <SafeMindPost>[];

          return StreamBuilder<List<SafeMindComment>>(
            stream: SafeMindBackend.instance.watchCommentsByAuthor(userId),
            builder: (context, commentsSnapshot) {
              final comments = commentsSnapshot.data ?? const <SafeMindComment>[];

              return DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: SectionCard(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: isAnonymous ? AppColors.secondary : AppColors.primary,
                              child: Text(
                                userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          userName,
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                                        ),
                                      ),
                                      if (isAnonymous)
                                        const _Badge(label: 'anonymous'),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Posts: ${posts.length}  ·  Comments: ${comments.length}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'All previous posts and comments from this account',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const TabBar(
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.muted,
                      tabs: [
                        Tab(text: 'Posts'),
                        Tab(text: 'Comments'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _PostsTab(posts: posts, userId: userId),
                          _CommentsTab(comments: comments, posts: posts),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PostsTab extends StatelessWidget {
  const _PostsTab({required this.posts, required this.userId});

  final List<SafeMindPost> posts;
  final String userId;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return _EmptyState(
        icon: Icons.article_outlined,
        title: 'No posts yet',
        message: 'This account has not shared any posts yet.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final post = posts[index];
        return PostCard(
          post: post,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PostDetailsScreen(postId: post.id)),
          ),
          onSupport: () => SafeMindBackend.instance.supportPost(post.id),
          onAuthorTap: null,
        );
      },
    );
  }
}

class _CommentsTab extends StatelessWidget {
  const _CommentsTab({required this.comments, required this.posts});

  final List<SafeMindComment> comments;
  final List<SafeMindPost> posts;

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return _EmptyState(
        icon: Icons.chat_bubble_outline,
        title: 'No comments yet',
        message: 'This account has not commented on any posts yet.',
      );
    }

    final postById = {for (final post in posts) post.id: post};

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: comments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final comment = comments[index];
        final sourcePost = postById[comment.postId];

        return SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sourcePost?.content ?? 'Original post',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                comment.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.text, height: 1.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Comment on ${sourcePost?.category ?? 'post'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: AppColors.muted),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.warm,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 11),
      ),
    );
  }
}