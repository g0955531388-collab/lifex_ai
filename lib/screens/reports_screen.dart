import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../features/profile/multi_profile_engine.dart';
import '../features/reports/stamped_report.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ActiveProfileController>().profile;
    return Scaffold(
      appBar: AppBar(title: const Text('التقارير النظامية')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'يحق لصاحب الحساب أو الوحدة استخراج ما هو مخوّل به: نص، PDF لاحقاً، أو أوفيس. لا أسماء على الجداول العامة.',
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: profile == null
                ? null
                : () {
                    final text = StampedReport(
                      profile: profile,
                      bodyAr: 'ملخص السيرة الحالية:\n'
                          'العمر: ${profile.ageYears ?? '—'}\n'
                          'الفصيلة: ${profile.bloodType.isEmpty ? '—' : profile.bloodType}',
                    ).toPlainText();
                    Share.share(text);
                  },
            child: const Text('مشاركة تقرير السيرة'),
          ),
        ],
      ),
    );
  }
}
