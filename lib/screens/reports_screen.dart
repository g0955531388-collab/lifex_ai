import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/care_store.dart';
import '../core/outbound.dart';
import '../features/profile/multi_profile_engine.dart';
import '../features/reports/report_export.dart';
import '../features/reports/stamped_report.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  StampedReport _report(profile, CareStore store) {
    final bag = store.bag(profile.profileId);
    final meds =
        bag.medications.map((m) => '${m.legalDrugName} ${m.doseText}').join('\n');
    final episodes = bag.episodes.map((e) => e.summaryAr).join('\n');
    final labs = bag.orders
        .where((o) => o.status == 'ready')
        .map((o) => '${o.unitType}: ${o.resultAr}')
        .join('\n');
    return StampedReport(
      profile: profile,
      bodyAr: 'ملخص السيرة الحالية:\n'
          'العمر: ${profile.ageYears ?? '—'}\n'
          'الفصيلة: ${profile.bloodType.isEmpty ? '—' : profile.bloodType}\n'
          'المدينة: ${profile.city.isEmpty ? '—' : profile.city}\n'
          'حساسيات: ${profile.allergies.isEmpty ? '—' : profile.allergies.join('، ')}\n'
          'أدوية:\n${meds.isEmpty ? '—' : meds}\n'
          'نتائج وحدات:\n${labs.isEmpty ? '—' : labs}\n'
          'حلقات مستشفى في السيرة:\n${episodes.isEmpty ? '—' : episodes}',
    );
  }

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
            'يحق لصاحب الحساب استخراج سيرته واستبيانه وأدويته ومواعيده وتحاليله كنص أو ملف للطباعة/أوفيس. لا إرسال سري تلقائي.',
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: profile == null
                ? null
                : () => Share.share(_report(profile, store).toPlainText()),
            child: const Text('مشاركة نص'),
          ),
          OutlinedButton(
            onPressed: profile == null
                ? null
                : () async {
                    final file =
                        await ReportExport().writePlainFile(_report(profile, store));
                    await Share.shareXFiles(
                      [XFile(file.path)],
                      text: 'تقرير Lifex مخوّل',
                    );
                  },
            child: const Text('ملف للطباعة أو أوفيس'),
          ),
          if (profile != null && profile.phone.isNotEmpty) ...[
            OutlinedButton(
              onPressed: () => Outbound.whatsApp(
                profile.phone,
                _report(profile, store).toPlainText(),
              ),
              child: const Text('واتساب'),
            ),
            OutlinedButton(
              onPressed: () => Outbound.sms(
                profile.phone,
                _report(profile, store).toPlainText(),
              ),
              child: const Text('رسائل'),
            ),
          ],
          if (profile != null && profile.email.isNotEmpty)
            OutlinedButton(
              onPressed: () => Outbound.email(
                profile.email,
                'تقرير Lifex',
                _report(profile, store).toPlainText(),
              ),
              child: const Text('بريد'),
            ),
        ],
      ),
    );
  }
}
