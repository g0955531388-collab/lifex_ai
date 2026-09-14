import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/app_constants.dart';
import '../core/care_store.dart';
import '../features/profile/multi_profile_engine.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _body = TextEditingController();

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ActiveProfileController>().profile;
    final store = context.watch<CareStore>();
    if (profile == null) {
      return const Scaffold(body: Center(child: Text('لا يوجد ملف نشط')));
    }
    final messages = store.bag(profile.profileId).chat;
    return Scaffold(
      appBar: AppBar(title: const Text('محادثة Lifex')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'للملفات الكبيرة والتقارير. لا إرسال سري تلقائي. لا إغراق سير الآخرين.',
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                for (final m in messages)
                  Align(
                    alignment:
                        m.fromSelf ? Alignment.centerRight : Alignment.centerLeft,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(m.bodyAr),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _body,
                    decoration: const InputDecoration(hintText: 'رسالة'),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if (_body.text.trim().isEmpty) return;
                    await store.mutate(profile.profileId, (bag) {
                      bag.chat.add(
                        ChatMessage(
                          id: newCareId(),
                          bodyAr: _body.text.trim(),
                        ),
                      );
                    });
                    _body.clear();
                  },
                  icon: const Icon(Icons.send),
                ),
                IconButton(
                  onPressed: () => Share.share(
                    messages.map((m) => m.bodyAr).join('\n'),
                  ),
                  icon: const Icon(Icons.share),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(AppConstants.medicalDisclaimer),
          ),
        ],
      ),
    );
  }
}
