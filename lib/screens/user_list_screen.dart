import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/backend_service.dart';
import '../theme/app_theme.dart';
import 'message_detail_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start a conversation'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: StreamBuilder<SafeMindUser?>(
        stream: SafeMindBackend.instance.authStateChanges(),
        builder: (context, userSnapshot) {
          final currentUser = userSnapshot.data;
          if (currentUser == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<List<SafeMindUser>>(
            stream: SafeMindBackend.instance.watchUsers(),
            builder: (context, userListSnapshot) {
              if (userListSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              var users = userListSnapshot.data ?? [];
              
              // Filter out current user and anonymous users
              users = users.where((u) => u.id != currentUser.id && !u.isAnonymous && !u.isBanned).toList();

              // Separate admin and regular users
              final adminUsers = users.where((u) => u.role == 'admin').toList();
              final advisorUsers = users.where((u) => u.role == 'advisor').toList();
              final regularUsers = users.where((u) => u.role == 'user').toList();

              // Apply search filter
              if (_searchQuery.isNotEmpty) {
                users = users
                    .where((u) => u.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                                  (u.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false))
                    .toList();
              }

              if (users.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_outline, size: 64, color: AppColors.muted),
                      const SizedBox(height: 16),
                      Text(
                        'No users found',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search users...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        if (adminUsers.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                            child: Text(
                              'ADMINS',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.muted,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...adminUsers.map((user) => _buildUserTile(context, currentUser, user)),
                        ],
                        if (advisorUsers.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                            child: Text(
                              'ADVISORS',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.muted,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...advisorUsers.map((user) => _buildUserTile(context, currentUser, user)),
                        ],
                        if (regularUsers.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                            child: Text(
                              'USERS',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.muted,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...regularUsers.map((user) => _buildUserTile(context, currentUser, user)),
                        ],
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

  Widget _buildUserTile(BuildContext context, SafeMindUser currentUser, SafeMindUser user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: user.role == 'admin' ? Colors.red : (user.role == 'advisor' ? Colors.blue : AppColors.primary),
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(user.name),
      subtitle: Text(user.email ?? ''),
      trailing: user.role != 'user' ? Chip(label: Text(user.role.toUpperCase())) : null,
      onTap: () {
        final conversationId = _makeConversationId(currentUser.id, user.id);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MessageDetailScreen(
              conversationId: conversationId,
              otherUserId: user.id,
              otherUserName: user.name,
            ),
          ),
        );
      },
    );
  }

  String _makeConversationId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return 'conv-${ids[0]}-${ids[1]}';
  }
}
