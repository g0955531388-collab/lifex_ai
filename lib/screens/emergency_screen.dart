import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../core/care_store.dart';
import '../core/outbound.dart';
import '../features/emergency/emergency_kit.dart';
import '../features/lost_phone/lost_phone_policy.dart';
import '../features/profile/multi_profile_engine.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final _phone = TextEditingController();
  final _registry = EmergencyPhoneContactsRegistry();
  final _risk = RiskLevelEngine();
  final _policy = LostPhonePolicy();
  String _status = '';

  void _hydrate(List<String> phones, String profileId) {
    for (final phone in phones) {
      _registry.addContact(profileId: profileId, phoneNumber: phone);
    }
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ActiveProfileController>().profile;
    final store = context.watch<CareStore>();
    final id = profile?.profileId ?? 'none';
    if (profile != null) {
      _hydrate(store.bag(id).emergencyPhones, id);
    }
    final contacts = _registry.contactsFor(id);
    return Scaffold(
      appBar: AppBar(title: const Text('طوارئ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'لا إرسال استغاثة تلقائي من كلمة في المحادثة. أكّد هنا. لا تصوير خفي.',
          ),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'رقم موثوق (حتى 10)'),
          ),
          OutlinedButton(
            onPressed: profile == null
                ? null
                : () async {
                    final r = _registry.addContact(
                      profileId: id,
                      phoneNumber: _phone.text,
                    );
                    if (r.success) {
                      await store.mutate(id, (bag) {
                        if (!bag.emergencyPhones.contains(_phone.text.trim())) {
                          bag.emergencyPhones.add(_phone.text.trim());
                        }
                      });
                    }
                    setState(() => _status = r.messageAr);
                  },
            child: const Text('إضافة رقم'),
          ),
          Text('الأرقام: ${contacts.map((c) => c.phoneNumber).join('، ')}'),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB71C1C)),
            onPressed: () async {
              final assessment = _risk.assess({
                'triggerType': 'user_confirmed_emergency',
                'hasChronicCondition': profile?.chronicAccredited ?? false,
                'age': profile?.ageYears,
              });
              setState(() {
                _status =
                    'تأكيد يدوي. المستوى: ${assessment.level}. ${contacts.length} أرقام.\n${assessment.reasonAr}';
              });
              HapticFeedback.heavyImpact();
              if (contacts.isNotEmpty) {
                await Outbound.sms(
                  contacts.first.phoneNumber,
                  'استغاثة Lifex مؤكدة من ${profile?.displayNameForCare() ?? ''}',
                );
              }
            },
            child: const Text('تأكيد إرسال استغاثة'),
          ),
          if (contacts.isNotEmpty)
            OutlinedButton(
              onPressed: () => Outbound.dial(contacts.first.phoneNumber),
              child: const Text('اتصال ظاهر بالرقم الأول'),
            ),
          const Divider(),
          const Text('أذن رقمية (اختيار)'),
          SwitchListTile(
            title: const Text('تفعيل مسار الصرخة/الأنين كإشارة طوارئ فقط'),
            subtitle: const Text(
              'يعمل وأنت في هذه الشاشة بموافقة. ليس تجسساً خلفياً. الميكروفون المستمر لاحقاً بعد مراجعة المتجر.',
            ),
            value: profile == null
                ? false
                : store.bag(id).digitalEarOptIn,
            onChanged: profile == null
                ? null
                : (v) => store.mutate(id, (bag) => bag.digitalEarOptIn = v),
          ),
          if (profile != null && store.bag(id).digitalEarOptIn)
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _status =
                      'إشارة صوتية يدوية. أكّد الاستغاثة بالزر الأحمر. لا إرسال تلقائي.';
                });
              },
              child: const Text('سمعت استغاثة — افتح التأكيد'),
            ),
          const Divider(),
          Text(_policy.nearbyActionAr()),
          OutlinedButton(
            onPressed: () async {
              await SystemSound.play(SystemSoundType.alert);
              HapticFeedback.vibrate();
              setState(() => _status = 'إنذار قريب ظاهر: أنا هنا.');
            },
            child: const Text('جوالي قريب — إنذار ظاهر'),
          ),
          Text(_policy.farSmsTemplate('****')),
          Text(_policy.simChangeWithoutPinAr()),
          if (_status.isNotEmpty) Text(_status),
          const Text(AppConstants.medicalDisclaimer),
        ],
      ),
    );
  }
}
