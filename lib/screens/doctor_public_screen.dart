import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/app_constants.dart';
import '../core/care_store.dart';
import '../core/outbound.dart';
import '../features/doctors/doctor_directory.dart';
import '../features/profile/multi_profile_engine.dart';
import '../features/reports/stamped_report.dart';

class DoctorPublicScreen extends StatefulWidget {
  const DoctorPublicScreen({super.key});

  @override
  State<DoctorPublicScreen> createState() => _DoctorPublicScreenState();
}

class _DoctorPublicScreenState extends State<DoctorPublicScreen> {
  String? _filterSpecialty;
  String _newSpecialty = DoctorDirectory.specialtiesAr.first;
  final _name = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _km = TextEditingController(text: '1');
  final _lat = TextEditingController();
  final _lng = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _address.dispose();
    _phone.dispose();
    _km.dispose();
    _lat.dispose();
    _lng.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ActiveProfileController>().profile;
    final store = context.watch<CareStore>();
    if (profile == null) {
      return const Scaffold(body: Center(child: Text('لا يوجد ملف نشط')));
    }
    final doctors = DoctorDirectory().nearestFirst(
      store.bag(profile.profileId).doctors,
      specialty: _filterSpecialty,
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.brandTeal,
        title: const Text('الأطباء'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'الاختصاص ثم الأقرب فالأبعد. الصفحة العامة: اسم واختصاص وتواصل وعنوان وجدول. بلا أسماء مرضى.',
          ),
          OutlinedButton(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('إذن الموقع'),
                  content: const Text(
                    'لترتيب الأطباء من الأقرب فالأبعد. يُستخدم عند هذه الشاشة فقط.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('رفض'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('موافق'),
                    ),
                  ],
                ),
              );
              if (ok != true || !context.mounted) return;
              try {
                final pos = await Geolocator.getCurrentPosition();
                await store.mutate(profile.profileId, (bag) {
                  bag.lastLat = pos.latitude;
                  bag.lastLng = pos.longitude;
                  DoctorDirectory().applyUserLocation(
                    bag.doctors,
                    userLat: pos.latitude,
                    userLng: pos.longitude,
                  );
                });
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'تعذر الموقع. أدخل المسافة أو إحداثيات العيادة يدوياً.',
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text('ترتيب حسب موقعي'),
          ),
          DropdownButton<String?>(
            value: _filterSpecialty,
            isExpanded: true,
            hint: const Text('كل الاختصاصات'),
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('كل الاختصاصات')),
              for (final s in DoctorDirectory.specialtiesAr)
                DropdownMenuItem(value: s, child: Text(s)),
            ],
            onChanged: (v) => setState(() => _filterSpecialty = v),
          ),
          if (doctors.isEmpty)
            const Text('لا أطباء مسجّلين بعد. أضف جهة حقيقية بلا أسماء تجريبية.')
          else
            for (final doc in doctors)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        doc.displayName.isEmpty ? 'طبيب' : doc.displayName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppConstants.brandTeal,
                        ),
                      ),
                      Text('${doc.specialtyAr} · ${doc.km} كم'),
                      Text(doc.address),
                      Text(doc.city),
                      const Text('مواعيد: شاغر / محجوز بلا اسم'),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilledButton(
                            onPressed: () async {
                              await store.mutate(profile.profileId, (bag) {
                                bag.doctors
                                    .firstWhere((d) => d.id == doc.id)
                                    .accredited = !doc.accredited;
                              });
                            },
                            child: Text(
                              doc.accredited ? 'طبيبي المعتمد' : 'اعتماد',
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () async {
                              await store.mutate(profile.profileId, (bag) {
                                bag.doctors
                                    .firstWhere((d) => d.id == doc.id)
                                    .following = !doc.following;
                              });
                            },
                            child: Text(doc.following ? 'تتابع' : 'متابعة'),
                          ),
                          if (doc.phone.isNotEmpty)
                            OutlinedButton(
                              onPressed: () => Outbound.whatsApp(
                                doc.phone,
                                StampedReport(
                                  profile: profile,
                                  bodyAr: 'تقرير للإرسال إلى الطبيب المعتمد.',
                                ).toPlainText(),
                              ),
                              child: const Text('واتساب التقرير'),
                            ),
                          if (doc.phone.isNotEmpty)
                            OutlinedButton(
                              onPressed: () => Share.share(
                                StampedReport(
                                  profile: profile,
                                  bodyAr: 'تقرير للطبيب.',
                                ).toPlainText(),
                              ),
                              child: const Text('مشاركة'),
                            ),
                        ],
                      ),
                      if (doc.accredited)
                        const Text(
                          'سيُخطر الطبيب ويُفتح له الوصول إلى سيرتك بعد التأكيد. المتابعة بلا سيرة.',
                        ),
                    ],
                  ),
                ),
              ),
          const Divider(),
          const Text('تسجيل جهة من حساب الوحدة'),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'اسم الطبيب أو العيادة'),
          ),
          DropdownButton<String>(
            value: _newSpecialty,
            isExpanded: true,
            items: [
              for (final s in DoctorDirectory.specialtiesAr)
                DropdownMenuItem(value: s, child: Text(s)),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _newSpecialty = v);
            },
          ),
          TextField(
            controller: _city,
            decoration: const InputDecoration(labelText: 'المدينة'),
          ),
          TextField(
            controller: _address,
            decoration: const InputDecoration(labelText: 'العنوان'),
          ),
          TextField(
            controller: _phone,
            decoration: const InputDecoration(labelText: 'هاتف/واتساب'),
          ),
          TextField(
            controller: _km,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'المسافة كم من موقعك'),
          ),
          TextField(
            controller: _lat,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'خط العرض (اختياري)'),
          ),
          TextField(
            controller: _lng,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'خط الطول (اختياري)'),
          ),
          FilledButton(
            onPressed: () async {
              await store.mutate(profile.profileId, (bag) {
                bag.doctors.add(
                  SavedDoctor(
                    id: newCareId(),
                    specialtyAr: _newSpecialty,
                    displayName: _name.text.trim(),
                    city: _city.text.trim().isEmpty
                        ? profile.city
                        : _city.text.trim(),
                    address: _address.text.trim(),
                    phone: _phone.text.trim(),
                    km: double.tryParse(_km.text) ?? 0,
                    lat: double.tryParse(_lat.text),
                    lng: double.tryParse(_lng.text),
                  ),
                );
              });
            },
            child: const Text('حفظ الجهة'),
          ),
        ],
      ),
    );
  }
}
