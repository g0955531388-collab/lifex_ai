import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../features/emergency/emergency_kit.dart';
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
  String _status = '';

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ActiveProfileController>().profile;
    final id = profile?.profileId ?? 'none';
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
            onPressed: () {
              final r = _registry.addContact(profileId: id, phoneNumber: _phone.text);
              setState(() => _status = r.messageAr);
            },
            child: const Text('إضافة رقم'),
          ),
          Text('الأرقام: ${_registry.contactsFor(id).map((c) => c.phoneNumber).join('، ')}'),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB71C1C)),
            onPressed: () {
              final assessment = _risk.assess({
                'triggerType': 'user_confirmed_emergency',
              });
              setState(() {
                _status =
                    'تأكيد يدوي. المستوى: ${assessment.level}. ${_registry.contactsFor(id).length} أرقام ستُخطر عند ربط SMS الرسمي.\n${assessment.reasonAr}';
              });
            },
            child: const Text('تأكيد إرسال استغاثة'),
          ),
          if (_status.isNotEmpty) Text(_status),
          const Text(AppConstants.medicalDisclaimer),
        ],
      ),
    );
  }
}
