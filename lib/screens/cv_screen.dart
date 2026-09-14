import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../features/profile/multi_profile_engine.dart';
import '../widgets/voice_fill.dart';
import 'meds_screen.dart';

class CvScreen extends StatefulWidget {
  const CvScreen({super.key});

  @override
  State<CvScreen> createState() => _CvScreenState();
}

class _CvScreenState extends State<CvScreen> {
  late final TextEditingController _age;
  late final TextEditingController _blood;
  late final TextEditingController _height;
  late final TextEditingController _weight;
  late final TextEditingController _city;
  late final TextEditingController _allergy;

  @override
  void initState() {
    super.initState();
    final p = context.read<ActiveProfileController>().profile;
    _age = TextEditingController(text: p?.ageYears?.toString() ?? '');
    _blood = TextEditingController(text: p?.bloodType ?? '');
    _height = TextEditingController(text: p?.heightCm?.toString() ?? '');
    _weight = TextEditingController(text: p?.weightKg?.toString() ?? '');
    _city = TextEditingController(text: p?.city ?? '');
    _allergy = TextEditingController();
  }

  @override
  void dispose() {
    _age.dispose();
    _blood.dispose();
    _height.dispose();
    _weight.dispose();
    _city.dispose();
    _allergy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ActiveProfileController>();
    final p = controller.profile;
    if (p == null) {
      return const Scaffold(body: Center(child: Text('لا يوجد ملف نشط')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('السيرة الصحية')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('الاسم الحقيقي: ${p.legalName}'),
          Text('المستعار: ${p.alias.isEmpty ? '—' : p.alias}'),
          Text('الصورة: ${p.hasRequiredPhoto ? 'مرفقة' : 'ناقصة'}'),
          TextField(
            controller: _age,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'العمر'),
          ),
          TextField(
            controller: _blood,
            decoration: const InputDecoration(labelText: 'فصيلة الدم'),
          ),
          TextField(
            controller: _height,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'الطول سم'),
          ),
          TextField(
            controller: _weight,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'الوزن كغ'),
          ),
          TextField(
            controller: _city,
            decoration: const InputDecoration(labelText: 'المدينة'),
          ),
          SwitchListTile(
            title: const Text('حمل على هذا الملف'),
            value: p.pregnant,
            onChanged: (v) => controller.update((x) => x.pregnant = v),
          ),
          TextField(
            controller: _allergy,
            decoration: const InputDecoration(labelText: 'إضافة حساسية'),
          ),
          VoiceFillButton(
            onText: (t) {
              if (t.isEmpty) return;
              _allergy.text = t;
              setState(() {});
            },
          ),
          OutlinedButton(
            onPressed: () async {
              final text = _allergy.text.trim();
              if (text.isEmpty) return;
              await controller.update((x) {
                if (!x.allergies.contains(text)) {
                  x.allergies.add(text);
                }
              });
              _allergy.clear();
            },
            child: const Text('حفظ الحساسية'),
          ),
          Text(
            p.allergies.isEmpty
                ? 'لا حساسيات مسجّلة'
                : 'حساسيات: ${p.allergies.join('، ')}',
          ),
          const SizedBox(height: 8),
          const Text(AppConstants.medicalDisclaimer),
          FilledButton(
            onPressed: () async {
              await controller.update((profile) {
                profile.ageYears = int.tryParse(_age.text);
                profile.bloodType = _blood.text.trim();
                profile.heightCm = double.tryParse(_height.text);
                profile.weightKg = double.tryParse(_weight.text);
                profile.city = _city.text.trim();
              });
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حفظ السيرة')),
                );
              }
            },
            child: const Text('حفظ'),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const MedsScreen()),
              );
            },
            child: const Text('جدول الدواء لهذا الملف'),
          ),
        ],
      ),
    );
  }
}
