import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../core/local_knowledge.dart';
import '../features/ai/local_ai_gateway.dart';
import '../features/profile/multi_profile_engine.dart';
import '../widgets/voice_fill.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final _q = TextEditingController();
  String _answer = '';

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ActiveProfileController>().profile;
    final knowledge = context.read<LocalKnowledge>();
    return Scaffold(
      appBar: AppBar(title: const Text('مساعد Lifex المحلي')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'الجواب من السيرة والمرجع المحلي على الجهاز. البحث في الويب فقط إذا كتبت: ابحث في الويب.',
          ),
          TextField(
            controller: _q,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'سؤالك الصحي'),
          ),
          VoiceFillButton(
            onText: (t) {
              if (t.isEmpty) return;
              _q.text = t;
              setState(() {});
            },
          ),
          FilledButton(
            onPressed: () {
              final reply = LocalAiGateway(knowledge).answer(
                question: _q.text,
                profile: profile,
              );
              setState(() => _answer = reply.textAr);
            },
            child: const Text('إجابة محلية'),
          ),
          if (_answer.isNotEmpty) Text(_answer),
          const SizedBox(height: 12),
          const Text(AppConstants.medicalDisclaimer),
        ],
      ),
    );
  }
}
