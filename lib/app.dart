import 'package:flutter/material.dart';

import 'models/app_user.dart';
import 'screens/admin_screen.dart';
import 'screens/chat_page.dart';
import 'screens/create_post_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/safety_screen.dart';
import 'screens/sign_up_screen.dart';
import 'services/backend_service.dart';
import 'theme/app_theme.dart';
import 'widgets/section_card.dart';

class SafeMindApp extends StatelessWidget {
  const SafeMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeMind',
      theme: AppTheme.light,
      home: const AuthGate(),
      routes: {
        '/signup': (context) => const SignUpScreen(),
        '/create': (context) => const CreatePostScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/admin': (context) => const AdminGate(),
        '/chat': (context) => const ChatPage(),
        '/messages': (context) => const MessagesScreen(),
        '/safety': (context) => const SafetyScreen(),
      },
    );
  }
}

class AdminGate extends StatelessWidget {
  const AdminGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SafeMindUser?>(
      stream: SafeMindBackend.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (user == null) {
          return const LoginScreen();
        }

        if (user.role != 'admin') {
          return Scaffold(
            appBar: AppBar(title: const Text('Admin Dashboard')),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: SectionCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock_outline, size: 40, color: AppColors.primary),
                        SizedBox(height: 12),
                        Text('Admin access required', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                        SizedBox(height: 8),
                        Text('This dashboard is available only for accounts with the admin role. Ask your Firebase admin to set your user document role to admin.'),
                      ],
                    ),
                  ),
                ),
              ),
              
            ),
          );
        }

        return const AdminScreen();
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Stream<SafeMindUser?> _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = SafeMindBackend.instance.authStateChanges();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SafeMindUser?>(
      key: const ValueKey('auth_gate'),
      stream: _authStream,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final connectionState = snapshot.connectionState;
        
        // ignore: avoid_print
        print('AuthGate: connectionState=$connectionState, user=${user?.id}, role=${user?.role}');

        if (snapshot.hasError) {
          // ignore: avoid_print
          print('AuthGate error: ${snapshot.error}');
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Connection Error', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(snapshot.error.toString()),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Only show loading if we have no data AND waiting
        if (connectionState == ConnectionState.waiting && user == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // No user - show login
        if (user == null) {
          // ignore: avoid_print
          print('AuthGate: user is null, showing LoginScreen');
          return const LoginScreen();
        }

        // User is admin - show admin dashboard
        if (user.role == 'admin') {
          // ignore: avoid_print
          print('AuthGate: user is admin (${user.id}), showing AdminGate');
          return const AdminGate();
        }

        // Regular/advisor user - show home
        // ignore: avoid_print
        print('AuthGate: user is ${user.role} (${user.id}), showing HomeScreen');
        return const HomeScreen();
      },
    );
  }
}