import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../core/care_store.dart';
import '../features/dental/dental_chart.dart';
import '../features/profile/multi_profile_engine.dart';

class DentalScreen extends StatefulWidget {
  const DentalScreen({super.key});

  @override
  State<DentalScreen> createState() => _DentalScreenState();
}

class _DentalScreenState extends State<DentalScreen> {
  final _note = TextEditingController();
  final _visit = TextEditingController();
  int _tooth = DentalChart.fdiAdult.first;

  @override
  void dispose() {
    _note.dispose();
    _visit.dispose();
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
    final chart = DentalChart(notes: bag.dentalNotes, nextVisit: bag.nextDentalVisit);
    return Scaffold(
      appBar: AppBar(title: const Text('الأسنان')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'جدول على مستوى السن. الزيارة التالية ومخبر التركيبات والأشعة على نفس الخيط.',
          ),
          DropdownButton<int>(
            value: _tooth,
            isExpanded: true,
            items: [
              for (final t in DentalChart.fdiAdult)
                DropdownMenuItem(value: t, child: Text('سن $t')),
            ],
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                _tooth = v;
                _note.text = chart.noteFor(v);
              });
            },
          ),
          TextField(
            controller: _note,
            decoration: const InputDecoration(labelText: 'ملاحظة هذا السن'),
          ),
          TextField(
            controller: _visit,
            decoration: InputDecoration(
              labelText: 'الزيارة التالية',
              hintText: bag.nextDentalVisit.isEmpty ? null : bag.nextDentalVisit,
            ),
          ),
          FilledButton(
            onPressed: () async {
              await store.mutate(profile.profileId, (b) {
                if (_note.text.trim().isEmpty) {
                  b.dentalNotes.remove('$_tooth');
                } else {
                  b.dentalNotes['$_tooth'] = _note.text.trim();
                }
                if (_visit.text.trim().isNotEmpty) {
                  b.nextDentalVisit = _visit.text.trim();
                }
              });
            },
            child: const Text('حفظ السن'),
          ),
          const Divider(),
          for (final tooth in DentalChart.fdiAdult)
            if ((bag.dentalNotes['$tooth'] ?? '').isNotEmpty)
              ListTile(
                title: Text('سن $tooth'),
                subtitle: Text(bag.dentalNotes['$tooth']!),
              ),
          if (bag.nextDentalVisit.isNotEmpty)
            Text('الزيارة التالية: ${bag.nextDentalVisit}'),
          const Text(AppConstants.medicalDisclaimer),
        ],
      ),
    );
  }
}
