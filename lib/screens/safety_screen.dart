import 'package:flutter/material.dart';

import '../widgets/section_card.dart';

class SafetyScreen extends StatelessWidget {
  const SafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safety & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SectionCard(
            child: Text('SafeMind is a peer-support app, not a replacement for professional or emergency care.', style: TextStyle(height: 1.5)),
          ),
          SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('If you are in immediate danger:', style: TextStyle(fontWeight: FontWeight.w700)),
                SizedBox(height: 8),
                Text('1. Contact your local emergency services.\n2. Reach out to a trusted person nearby.\n3. Go to the nearest hospital or campus support center.', style: TextStyle(height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}