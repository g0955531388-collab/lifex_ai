import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../features/profile/multi_profile_engine.dart';

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

  @override
  void initState() {
    super.initState();
    final p = context.read<ActiveProfileController>().profile;
    _age = TextEditingController(text: p?.ageYears?.toString() ?? '');
    _blood = TextEditingController(text: p?.bloodType ?? '');
    _height = TextEditingController(text: p?.heightCm?.toString() ?? '');
    _weight = TextEditingController(text: p?.weightKg?.toString() ?? '');
  }

  @override
  void dispose() {
    _age.dispose();
    _blood.dispose();
    _height.dispose();
    _weight.dispose();
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
          const SizedBox(height: 8),
          const Text(AppConstants.medicalDisclaimer),
          FilledButton(
            onPressed: () async {
              await controller.update((profile) {
                profile.ageYears = int.tryParse(_age.text);
                profile.bloodType = _blood.text.trim();
                profile.heightCm = double.tryParse(_height.text);
                profile.weightKg = double.tryParse(_weight.text);
              });
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حفظ السيرة')),
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
