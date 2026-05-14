import 'package:flutter/material.dart';

import '../services/backend_service.dart';
import 'login_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/section_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _mood = 3;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMood();
  }

  Future<void> _loadMood() async {
    try {
      final user = await SafeMindBackend.instance.currentUser();
      if (user != null && mounted) {
        final savedMood = await SafeMindBackend.instance.getUserMood(user.id);
        if (savedMood != null && mounted) {
          setState(() {
            _mood = savedMood;
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error loading mood: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _setMood(int mood) async {
    setState(() => _mood = mood);
    try {
      await SafeMindBackend.instance.saveMood(mood);
    } catch (e) {
      // ignore: avoid_print
      print('Error saving mood: $e');
    }
  }

  Future<void> _signOut() async {
    await SafeMindBackend.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            child: Column(
              children: [
                const CircleAvatar(radius: 40, backgroundColor: AppColors.secondary, child: Text('A', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700))),
                const SizedBox(height: 12),
                Text('Anonymous User', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Portfolio preview profile', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () => Navigator.pushNamed(context, '/safety'),
                  child: const Text('Safety & support resources'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _signOut,
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How are you feeling today?', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Wrap(
                    spacing: 8,
                    children: List.generate(5, (index) {
                      final value = index + 1;
                      final selected = _mood == value;
                      final moodEmojis = ['😢', '😞', '😐', '🙂', '😄'];
                      return FilterChip(
                        label: Text('${moodEmojis[index]} ${['Awful', 'Bad', 'Okay', 'Good', 'Great'][index]}'),
                        selected: selected,
                        onSelected: (_) => _setMood(value),
                        backgroundColor: selected ? AppColors.primary : Colors.transparent,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : AppColors.text,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      );
                    }),
                  ),
                const SizedBox(height: 12),
                Text(
                  'Your mood is displayed with your posts',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}