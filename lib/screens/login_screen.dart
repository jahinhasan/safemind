import 'package:flutter/material.dart';

import '../services/backend_service.dart';
import '../theme/app_theme.dart';
import '../widgets/section_card.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 24),
                const Icon(Icons.favorite, size: 64, color: AppColors.primary),
                const SizedBox(height: 12),
                Text('SafeMind', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: AppColors.text)),
                const SizedBox(height: 8),
                Text('A safe community for support.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.muted)),
                const SizedBox(height: 28),
                const SectionCard(child: _LoginForm()),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/safety'),
                  child: const Text('Need help now? Read the safety guide'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      // ignore: avoid_print
      print('Starting sign-in action');
      await action();
      // ignore: avoid_print
      print('Sign-in action completed');
    } catch (error) {
      if (!mounted) return;
      // ignore: avoid_print
      print('Login error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign-in failed: ${error.toString()}'),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.red[700],
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.email_outlined))),
        const SizedBox(height: 16),
        TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline))),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _busy ? null : () {
            // ignore: avoid_print
            print('Sign in button pressed with email: ${_emailController.text}');
            _run(() => SafeMindBackend.instance.signInWithEmailAndPassword(_emailController.text, _passwordController.text));
          },
          child: Text(_busy ? 'Signing in...' : 'Sign in'),
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: _busy ? null : () => _run(() => SafeMindBackend.instance.signInAnonymously()),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.visibility_off_outlined),
              const SizedBox(width: 8),
              Text(_busy ? 'Please wait...' : 'Continue anonymously'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Anonymous mode keeps your account active while hiding your identity from other members.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/signup'),
          child: const Text('Create a new account'),
        ),
      ],
    );
  }
}