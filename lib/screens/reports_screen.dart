import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/care_store.dart';
import '../features/profile/multi_profile_engine.dart';
import '../features/reports/stamped_report.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ActiveProfileController>().profile;
    final store = context.watch<CareStore>();
    return Scaffold(
      appBar: AppBar(title: const Text('التقارير النظامية')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'يحق لصاحب الحساب استخراج سيرته واستبيانه وأدويته ومواعيده وتحاليله. الطبيب المعتمد: السيرة المشاركة وحلقة العلاج. الوحدة: معاملاتها فقط. لا إرسال سري تلقائي.',
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: profile == null
                ? null
                : () {
                    final bag = store.bag(profile.profileId);
                    final meds = bag.medications
                        .map((m) => '${m.legalDrugName} ${m.doseText}')
                        .join('\n');
                    final episodes =
                        bag.episodes.map((e) => e.summaryAr).join('\n');
                    final labs = bag.orders
                        .where((o) => o.status == 'ready')
                        .map((o) => '${o.unitType}: ${o.resultAr}')
                        .join('\n');
                    final text = StampedReport(
                      profile: profile,
                      bodyAr: 'ملخص السيرة الحالية:\n'
                          'العمر: ${profile.ageYears ?? '—'}\n'
                          'الفصيلة: ${profile.bloodType.isEmpty ? '—' : profile.bloodType}\n'
                          'المدينة: ${profile.city.isEmpty ? '—' : profile.city}\n'
                          'حساسيات: ${profile.allergies.isEmpty ? '—' : profile.allergies.join('، ')}\n'
                          'أدوية:\n${meds.isEmpty ? '—' : meds}\n'
                          'نتائج وحدات:\n${labs.isEmpty ? '—' : labs}\n'
                          'حلقات مستشفى في السيرة:\n${episodes.isEmpty ? '—' : episodes}',
                    ).toPlainText();
                    Share.share(text);
                  },
            child: const Text('مشاركة تقرير السيرة المخوّل'),
          ),
        ],
      ),
    );
  }
}
