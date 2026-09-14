import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../features/family/genetics_signal.dart';
import '../features/profile/multi_profile_engine.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profiles = context.watch<ActiveProfileController>();
    final opted = profiles.all.where((p) => p.geneticsOptIn).toList();
    final signals = GeneticsSignalEngine().estimate(opted);
    return Scaffold(
      appBar: AppBar(title: const Text('العائلة والأنماط')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'ملفات على نفس التثبيت لمن لا يملكون هاتفاً. الهاتف لصاحب النسخة. الدواء يُنطق بالاسم الحقيقي لذلك الملف. لا دمج سير ولا قائمة عامة.',
          ),
          for (final p in profiles.all)
            ListTile(
              title: Text(p.displayNameForCare()),
              subtitle: Text(p.profileId == profiles.profile?.profileId ? 'نشط' : p.alias),
              trailing: Wrap(
                children: [
                  if (p.profileId != profiles.profile?.profileId)
                    TextButton(
                      onPressed: () => profiles.switchTo(p.profileId),
                      child: const Text('تفعيل'),
                    ),
                ],
              ),
            ),
          SwitchListTile(
            title: const Text('موافقة هذا الملف على تقدير أنماط عائلية'),
            value: profiles.profile?.geneticsOptIn ?? false,
            onChanged: profiles.profile == null
                ? null
                : (v) => profiles.update((p) => p.geneticsOptIn = v),
          ),
          for (final signal in signals)
            ListTile(
              title: Text(signal.messageAr),
            ),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'اسم حقيقي لملف جديد على هذا الهاتف'),
          ),
          FilledButton(
            onPressed: () async {
              if (_name.text.trim().isEmpty) return;
              await profiles.createLinked(legalName: _name.text.trim());
              _name.clear();
            },
            child: const Text('إضافة ملف عائلي فارغ'),
          ),
          const Text(AppConstants.medicalDisclaimer),
        ],
      ),
    );
  }
}
