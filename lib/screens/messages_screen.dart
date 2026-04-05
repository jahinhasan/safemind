import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/message_item.dart';
import '../services/backend_service.dart';
import '../theme/app_theme.dart';
import 'message_detail_screen.dart';
import 'user_list_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UserListScreen()));
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: StreamBuilder<SafeMindUser?>(
        stream: SafeMindBackend.instance.authStateChanges(),
        builder: (context, userSnapshot) {
          final currentUser = userSnapshot.data;
          if (currentUser == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<List<SafeMindConversation>>(
            stream: SafeMindBackend.instance.watchConversations(currentUser.id),
            builder: (context, conversationSnapshot) {
              if (conversationSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final conversations = conversationSnapshot.data ?? [];

              if (conversations.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mail_outline, size: 64, color: AppColors.muted),
                      const SizedBox(height: 16),
                      Text(
                        'No conversations yet',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.muted),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start a new message with anyone',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const UserListScreen()));
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Start conversation'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  
                  // Determine other user in conversation
                  final otherUserId = conversation.user1Id == currentUser.id ? conversation.user2Id : conversation.user1Id;
                  final otherUserName = conversation.user1Id == currentUser.id ? conversation.user2Name : conversation.user1Name;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(
                        otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(otherUserName),
                    subtitle: Text(
                      conversation.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      _formatTime(conversation.lastMessageTime),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.muted),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MessageDetailScreen(
                            conversationId: conversation.id,
                            otherUserId: otherUserId,
                            otherUserName: otherUserName,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
