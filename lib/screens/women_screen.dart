import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../core/care_store.dart';
import '../core/health_event_manager.dart';
import '../features/profile/multi_profile_engine.dart';
import '../features/women/cycle_engine.dart';

class WomenScreen extends StatefulWidget {
  const WomenScreen({super.key});

  @override
  State<WomenScreen> createState() => _WomenScreenState();
}

class _WomenScreenState extends State<WomenScreen> {
  final _engine = CycleEngine();
  final _newborn = TextEditingController();

  @override
  void dispose() {
    _newborn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profiles = context.watch<ActiveProfileController>();
    final profile = profiles.profile;
    final store = context.watch<CareStore>();
    if (profile == null) {
      return const Scaffold(body: Center(child: Text('لا يوجد ملف نشط')));
    }
    final bag = store.bag(profile.profileId);
    final starts = bag.cycleStartsIso
        .map(DateTime.parse)
        .toList()
      ..sort();
    final lmp = bag.pregnancyLmpIso.isEmpty
        ? null
        : DateTime.tryParse(bag.pregnancyLmpIso);
    return Scaffold(
      appBar: AppBar(title: const Text('صحة المرأة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'دورة، رسائل مكتومة، رعاية أربعين أسبوعاً. المولود يأخذ سيرة مستقلة. البيانات الحميمة لا تظهر على ملف آخر في نفس الهاتف.',
          ),
          SwitchListTile(
            title: const Text('حمل على هذا الملف فقط'),
            value: profile.pregnant,
            onChanged: (v) => profiles.update((p) => p.pregnant = v),
          ),
          FilledButton(
            onPressed: () async {
              await store.mutate(profile.profileId, (b) {
                b.cycleStartsIso.add(DateTime.now().toIso8601String());
              });
            },
            child: const Text('تسجيل بدء دورة اليوم'),
          ),
          if (_engine.cycleLengthDays(starts) != null)
            Text('متوسط الدورة التقريبي: ${_engine.cycleLengthDays(starts)} يوماً'),
          FilledButton(
            onPressed: () async {
              await store.mutate(profile.profileId, (b) {
                b.pregnancyLmpIso = DateTime.now().toIso8601String();
              });
              HealthEventManager.instance.emitQuick(
                HealthEventType.pregnancyMilestoneReached,
                sourceModule: 'women_screen',
                profileId: profile.profileId,
              );
            },
            child: const Text('تعيين آخر دورة كبداية حمل تقريبية'),
          ),
          if (lmp != null) ...[
            Text('الأسبوع التقريبي: ${_engine.pregnancyWeek(lmp) ?? '—'} / 40'),
            Text(
              'تاريخ الولادة التقريبي: ${_engine.dueDateFromLmp(lmp)!.toIso8601String().split('T').first}',
            ),
          ],
          const Divider(),
          TextField(
            controller: _newborn,
            decoration: const InputDecoration(labelText: 'اسم المولود الحقيقي لسيرة جديدة'),
          ),
          OutlinedButton(
            onPressed: () async {
              if (_newborn.text.trim().isEmpty) return;
              await profiles.createLinked(legalName: _newborn.text.trim());
            },
            child: const Text('إنشاء سيرة مستقلة للمولود'),
          ),
          const Text(AppConstants.medicalDisclaimer),
        ],
      ),
    );
  }
}
