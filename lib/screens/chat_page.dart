import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/section_card.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  final _messages = [
    {'author': 'Anonymous User', 'message': 'Breaking tasks into smaller parts helped me.', 'time': '2 hours ago'},
    {'author': 'You', 'message': 'Thanks, I will try that.', 'time': '1 hour ago'},
    {'author': 'Advisor', 'message': 'Keep your sleep schedule stable while studying.', 'time': '30 min ago'},
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Private Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isYou = message['author'] == 'You';
                final isAdvisor = message['author'] == 'Advisor';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: isYou ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isYou)
                        CircleAvatar(backgroundColor: isAdvisor ? AppColors.secondary : AppColors.warm, child: Icon(isAdvisor ? Icons.verified : Icons.person_outline, color: isAdvisor ? Colors.white : AppColors.primary)),
                      if (!isYou) const SizedBox(width: 10),
                      Flexible(
                        child: SectionCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(message['author']!, style: const TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(message['message']!, style: const TextStyle(height: 1.4)),
                              const SizedBox(height: 4),
                              Text(message['time']!, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, -4))]),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _messageController, decoration: const InputDecoration(hintText: 'Type your reply...'))),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () {
                    if (_messageController.text.trim().isEmpty) return;
                    setState(() {
                      _messages.add({'author': 'You', 'message': _messageController.text.trim(), 'time': 'just now'});
                    });
                    _messageController.clear();
                  },
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}