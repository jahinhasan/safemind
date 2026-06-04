import 'package:flutter/material.dart';

import '../models/comment_item.dart';
import '../models/post_item.dart';
import '../services/backend_service.dart';
import '../theme/app_theme.dart';
import '../widgets/comment_card.dart';
import '../widgets/post_card.dart';
import '../widgets/section_card.dart';
import 'user_activity_screen.dart';

class PostDetailsScreen extends StatefulWidget {
  const PostDetailsScreen({super.key, required this.postId});

  final String postId;

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _sendComment(String postId) async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;
    await SafeMindBackend.instance.addComment(postId, content);
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post details'),
        actions: [
          IconButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final reason = await showModalBottomSheet<String>(
                context: context,
                builder: (context) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ListTile(title: Text('Report content')),
                      ListTile(leading: const Icon(Icons.warning_amber_outlined), title: const Text('Harassment or abuse'), onTap: () => Navigator.pop(context, 'Harassment or abuse')),
                      ListTile(leading: const Icon(Icons.block), title: const Text('Spam or misleading'), onTap: () => Navigator.pop(context, 'Spam or misleading')),
                      ListTile(leading: const Icon(Icons.favorite_border), title: const Text('Self-harm risk'), onTap: () => Navigator.pop(context, 'Self-harm risk')),
                    ],
                  ),
                ),
              );
              if (!mounted) return;
              if (reason != null) {
                final currentPost = await SafeMindBackend.instance.getPost(widget.postId);
                if (currentPost == null) {
                  if (!mounted) return;
                  messenger.showSnackBar(const SnackBar(content: Text('Post is no longer available')));
                  return;
                }
                await SafeMindBackend.instance.reportContent(
                  targetType: 'post',
                  targetId: widget.postId,
                  reason: reason,
                  targetAuthorId: currentPost.authorId,
                  targetAuthorName: currentPost.authorName,
                  severity: reason.toLowerCase().contains('abuse') || reason.toLowerCase().contains('harm') ? 'high' : 'medium',
                );
                if (!mounted) return;
                messenger.showSnackBar(const SnackBar(content: Text('Report submitted')));
              }
            },
            icon: const Icon(Icons.flag_outlined),
          ),
        ],
      ),
      body: StreamBuilder<SafeMindPost?>(
        stream: SafeMindBackend.instance.watchPost(widget.postId),
        builder: (context, postSnapshot) {
          final post = postSnapshot.data;
          if (post == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<List<SafeMindComment>>(
            stream: SafeMindBackend.instance.watchComments(widget.postId),
            builder: (context, commentsSnapshot) {
              final comments = commentsSnapshot.data ?? const <SafeMindComment>[];
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  PostCard(
                    post: post,
                    onTap: () {},
                    onAuthorTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserActivityScreen(
                          userId: post.authorId,
                          userName: post.authorName,
                          isAnonymous: post.isAnonymous,
                        ),
                      ),
                    ),
                    onSupport: () => SafeMindBackend.instance.supportPost(post.id),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Responses (${comments.length})', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      if (post.solved)
                        const Text('Solved', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...comments.map(
                    (comment) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CommentCard(
                        comment: comment,
                        onMarkBest: () => SafeMindBackend.instance.markBestComment(postId: post.id, commentId: comment.id),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SectionCard(
                    child: Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline, color: AppColors.muted),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(hintText: 'Share your thoughts or advice...'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: () => _sendComment(post.id),
                          child: const Text('Send'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}