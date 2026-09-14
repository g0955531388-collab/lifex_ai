import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../core/care_store.dart';
import '../core/health_event_manager.dart';
import '../features/meds/medication_engine.dart';
import '../features/profile/multi_profile_engine.dart';

class MedsScreen extends StatefulWidget {
  const MedsScreen({super.key});

  @override
  State<MedsScreen> createState() => _MedsScreenState();
}

class _MedsScreenState extends State<MedsScreen> {
  final _name = TextEditingController();
  final _dose = TextEditingController();
  final _time = TextEditingController();
  final _engine = MedicationEngine();
  String _status = '';

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
    _time.dispose();
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
      appBar: AppBar(title: const Text('جدول الدواء')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'الجدول كما وصفه الطبيب. التعديل الإلكتروني من الطبيب يحدّث التذكير. Lifex لا يصف دواء.',
          ),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'الاسم القانوني للدواء'),
          ),
          TextField(
            controller: _dose,
            decoration: const InputDecoration(labelText: 'الجرعة كما في الوصفة'),
          ),
          TextField(
            controller: _time,
            decoration: const InputDecoration(labelText: 'وقت الجرعة'),
          ),
          FilledButton(
            onPressed: () async {
              final check = _engine.crossCheck(
                drugName: _name.text,
                profile: profile,
              );
              setState(() => _status = check.messageAr);
              if (!check.mayTakeNow) return;
              await store.mutate(profile.profileId, (bag) {
                bag.medications.add(
                  PrescribedMedication(
                    id: newCareId(),
                    legalDrugName: _name.text.trim(),
                    doseText: _dose.text.trim(),
                    timesAr: _time.text.trim().isEmpty
                        ? const []
                        : [_time.text.trim()],
                  ),
                );
              });
              HealthEventManager.instance.emitQuick(
                HealthEventType.medicationTaken,
                sourceModule: 'meds_screen',
                profileId: profile.profileId,
              );
            },
            child: const Text('حفظ الجرعة في هذا الملف'),
          ),
          if (_status.isNotEmpty) Text(_status),
          const Divider(),
          for (final med in bag.medications)
            ListTile(
              title: Text(med.legalDrugName),
              subtitle: Text('${med.doseText} · ${med.timesAr.join('، ')}'),
              trailing: IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: () async {
                  final check = _engine.crossCheck(
                    drugName: med.legalDrugName,
                    profile: profile,
                  );
                  final spoken = check.mayTakeNow
                      ? _engine.spokenDose(
                          profile: profile,
                          doseText: '${med.legalDrugName} ${med.doseText}',
                        )
                      : check.messageAr;
                  setState(() => _status = spoken);
                  try {
                    await FlutterTts().speak(spoken);
                  } catch (_) {}
                },
              ),
            ),
          const Text(AppConstants.medicalDisclaimer),
        ],
      ),
    );
  }
}
