import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/app_constants.dart';
import '../features/profile/multi_profile_engine.dart';
import '../features/reports/stamped_report.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final _notes = TextEditingController();
  final _region = TextEditingController();
  String? _reportText;

  @override
  void dispose() {
    _notes.dispose();
    _region.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ActiveProfileController>().profile;
    return Scaffold(
      appBar: AppBar(title: const Text('الاستبيان الصحي')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'سؤال وجواب، تصوير منطقة، أو أوراق عبر الكاميرا بعد الموافقة. هذه مسودة للطبيب.',
          ),
          TextField(
            controller: _region,
            decoration: const InputDecoration(labelText: 'المنطقة من الجسم أو الموضوع'),
          ),
          TextField(
            controller: _notes,
            maxLines: 6,
            decoration: const InputDecoration(labelText: 'ما تصفه أو ما قرأته الكاميرا'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: profile == null
                ? null
                : () {
                    final report = StampedReport(
                      profile: profile,
                      bodyAr: 'المنطقة: ${_region.text}\nالملاحظات:\n${_notes.text}',
                    );
                    setState(() => _reportText = report.toPlainText());
                  },
            child: const Text('استخراج التقرير المختوم'),
          ),
          if (_reportText != null) ...[
            const SizedBox(height: 12),
            Text(_reportText!),
            const Text(AppConstants.medicalDisclaimer),
            OutlinedButton(
              onPressed: () => Share.share(_reportText!),
              child: const Text('إرسال أو حفظ كنص'),
            ),
          ],
        ],
      ),
    );
  }
}
