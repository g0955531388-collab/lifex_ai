import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../core/care_store.dart';
import '../features/doctors/doctor_directory.dart';
import '../features/profile/multi_profile_engine.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  final _query = TextEditingController();
  final _name = TextEditingController();
  final _barcode = TextEditingController();
  final _city = TextEditingController();
  final _km = TextEditingController(text: '1');
  final _qty = TextEditingController(text: '1');

  @override
  void dispose() {
    _query.dispose();
    _name.dispose();
    _barcode.dispose();
    _city.dispose();
    _km.dispose();
    _qty.dispose();
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
    final hits = PharmacyLocator().nearestWithDrug(
      stock: bag.pharmacyStock,
      query: _query.text,
      city: profile.city,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('الصيدلية')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'باركود المخزون → أقرب صيدلية فيها الدواء في نفس المدينة → المريض يختار → الصيدلي يجهّز. لا بيع دم هنا.',
          ),
          TextField(
            controller: _query,
            decoration: const InputDecoration(labelText: 'اسم الدواء أو الباركود'),
            onChanged: (_) => setState(() {}),
          ),
          if (hits.isEmpty)
            const Text('لا مخزون مطابق بعد. الوحدة تضيف باركودها أدناه.')
          else
            for (final item in hits)
              ListTile(
                title: Text(item.nameAr),
                subtitle: Text(
                  '${item.city} · ${item.km} كم · كمية ${item.quantity} · ${item.barcode}',
                ),
              ),
          const Divider(),
          const Text('إضافة مخزون من حساب الوحدة (قالب محلي)'),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'اسم الصنف'),
          ),
          TextField(
            controller: _barcode,
            decoration: const InputDecoration(labelText: 'الباركود'),
          ),
          TextField(
            controller: _city,
            decoration: const InputDecoration(labelText: 'المدينة'),
          ),
          TextField(
            controller: _km,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'المسافة كم'),
          ),
          TextField(
            controller: _qty,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'الكمية'),
          ),
          FilledButton(
            onPressed: () async {
              await store.mutate(profile.profileId, (bag) {
                bag.pharmacyStock.add(
                  PharmacyStockItem(
                    id: newCareId(),
                    nameAr: _name.text.trim(),
                    barcode: _barcode.text.trim(),
                    city: _city.text.trim().isEmpty
                        ? profile.city
                        : _city.text.trim(),
                    km: double.tryParse(_km.text) ?? 0,
                    quantity: int.tryParse(_qty.text) ?? 0,
                  ),
                );
              });
            },
            child: const Text('حفظ الصنف'),
          ),
          const Text(AppConstants.medicalDisclaimer),
        ],
      ),
    );
  }
}
