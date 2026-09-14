import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../core/care_store.dart';
import '../features/profile/multi_profile_engine.dart';

class HospitalScreen extends StatefulWidget {
  const HospitalScreen({super.key});

  @override
  State<HospitalScreen> createState() => _HospitalScreenState();
}

class _HospitalScreenState extends State<HospitalScreen> {
  final _episode = TextEditingController();

  @override
  void dispose() {
    _episode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ActiveProfileController>().profile;
    final store = context.watch<CareStore>();
    if (profile == null) {
      return const Scaffold(body: Center(child: Text('لا يوجد ملف نشط')));
    }
    final bag = store.bag(profile.profileId);
    return Scaffold(
      appBar: AppBar(title: const Text('المستشفى')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'اشتراك المستشفى ${AppConstants.hospitalSubscriptionUsd} دولار/سنة. '
            'العامة مقابل الإدارة. الإحالة كطبيب موسّع. الحلقة تُعبأ في سيرة المريض. الإحصاء التشغيلي يبقى داخل المستشفى.',
          ),
          TextField(
            controller: _episode,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'ملخص الحلقة لهذه السيرة'),
          ),
          FilledButton(
            onPressed: () async {
              await store.mutate(profile.profileId, (b) {
                b.episodes.add(
                  HospitalEpisode(
                    id: newCareId(),
                    summaryAr: _episode.text.trim(),
                  ),
                );
              });
            },
            child: const Text('تعبئة الحلقة في السيرة'),
          ),
          const Divider(),
          for (final ep in bag.episodes)
            ListTile(
              title: Text(ep.summaryAr),
              subtitle: const Text('في السيرة · الإحصاء الداخلي غير ظاهر هنا'),
            ),
          const Text(AppConstants.medicalDisclaimer),
        ],
      ),
    );
  }
}
