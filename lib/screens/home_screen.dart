import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/post_item.dart';
import '../services/backend_service.dart';
import '../theme/app_theme.dart';
import '../widgets/post_card.dart';
import '../widgets/section_card.dart';
import 'post_details_screen.dart';
import 'user_activity_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filterType = 'all';

  List<SafeMindPost> _applyFilter(List<SafeMindPost> posts) {
    if (_filterType == 'unsolved') {
      return posts.where((post) => !post.solved).toList();
    }
    if (_filterType == 'trending') {
      final sorted = [...posts];
      sorted.sort((a, b) => b.supportCount.compareTo(a.supportCount));
      return sorted;
    }
    return posts;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SafeMindUser?>(
      stream: SafeMindBackend.instance.authStateChanges(),
      builder: (context, userSnapshot) {
        final user = userSnapshot.data;
        return Scaffold(
          appBar: AppBar(
            title: const Text('SafeMind'),
            actions: [
              IconButton(onPressed: () => Navigator.pushNamed(context, '/profile'), icon: const Icon(Icons.person_outline)),
              IconButton(onPressed: () => Navigator.pushNamed(context, '/messages'), icon: const Icon(Icons.mail_outline)),
              IconButton(onPressed: () => Navigator.pushNamed(context, '/chat'), icon: const Icon(Icons.chat_bubble_outline)),
              if (user?.role == 'admin') IconButton(onPressed: () => Navigator.pushNamed(context, '/admin'), icon: const Icon(Icons.shield_outlined)),
            ],
          ),
          body: StreamBuilder<List<SafeMindPost>>(
            stream: SafeMindBackend.instance.watchPosts(),
            builder: (context, snapshot) {
              final posts = _applyFilter(snapshot.data ?? const <SafeMindPost>[]);
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  Row(
                    children: [
                      Expanded(child: _FilterButton(label: 'All', value: 'all', active: _filterType, onTap: () => setState(() => _filterType = 'all'))),
                      const SizedBox(width: 10),
                      Expanded(child: _FilterButton(label: 'Needs Support', value: 'unsolved', active: _filterType, onTap: () => setState(() => _filterType = 'unsolved'))),
                      const SizedBox(width: 10),
                      Expanded(child: _FilterButton(label: 'Trending', value: 'trending', active: _filterType, onTap: () => setState(() => _filterType = 'trending'))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (posts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: Column(
                        children: [
                          const Icon(Icons.favorite_outline, size: 56, color: AppColors.muted),
                          const SizedBox(height: 12),
                          Text('No posts yet', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Text('Be the first to share your story.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
                        ],
                      ),
                    )
                  else
                    ...posts.map((post) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: PostCard(
                          post: post,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailsScreen(postId: post.id))),
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
                      );
                    }),
                  const SizedBox(height: 12),
                  const SectionCard(
                    child: Text('SafeMind is built for anonymity, support, and advisor guidance. Use the flag button in post details to report content.'),
                  ),
                ],
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, '/create'),
            backgroundColor: AppColors.secondary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.label, required this.value, required this.active, required this.onTap});

  final String label;
  final String value;
  final String active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = active == value;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.warm,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: selected ? Colors.white : AppColors.primary, fontWeight: FontWeight.w700)),
      ),
    );
  }
}