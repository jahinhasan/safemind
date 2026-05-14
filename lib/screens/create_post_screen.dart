import 'package:flutter/material.dart';

import '../services/backend_service.dart';
import '../widgets/section_card.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  static const categories = ['Anxiety', 'Depression', 'Stress', 'Relationships', 'Work', 'Family', 'General', 'Other'];

  final _contentController = TextEditingController();
  String _selectedCategory = 'General';
  bool _anonymous = true;
  bool _busy = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;
    setState(() => _busy = true);
    try {
      await SafeMindBackend.instance.createPost(content: content, category: _selectedCategory, anonymous: _anonymous);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Share Your Thoughts')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SwitchListTile.adaptive(
                      value: _anonymous,
                      title: const Text('Post anonymously'),
                      subtitle: const Text('Your identity will be hidden from the community.'),
                      onChanged: (value) => setState(() => _anonymous = value),
                    ),
                    const SizedBox(height: 12),
                    Text('Category', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((category) {
                        final selected = _selectedCategory == category;
                        return ChoiceChip(
                          label: Text(category),
                          selected: selected,
                          onSelected: (_) => setState(() => _selectedCategory = category),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _contentController,
                      maxLines: 8,
                      decoration: const InputDecoration(hintText: 'Share your thoughts, feelings, or ask for support...'),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: Text(_busy ? 'Posting...' : 'Post'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}