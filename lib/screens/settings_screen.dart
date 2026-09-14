import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../core/care_store.dart';
import '../features/lost_phone/lost_phone_policy.dart';
import '../features/profile/multi_profile_engine.dart';
import 'family_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _pin = TextEditingController();
  final _city = TextEditingController();
  String _lostStatus = '';

  @override
  void dispose() {
    _pin.dispose();
    _city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profiles = context.watch<ActiveProfileController>();
    final profile = profiles.profile;
    final store = context.watch<CareStore>();
    final bag = profile == null ? null : store.bag(profile.profileId);
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'الأذونات: شرح ثم موافقة ثم إدارة هنا. كاميرا وميكروفون وموقع عند الحاجة فقط. لا قراءة كل الرسائل ولا قفل إلغاء التثبيت.',
          ),
          const SizedBox(height: 8),
          if (profile != null) ...[
            TextField(
              controller: _city,
              decoration: InputDecoration(
                labelText: 'المدينة (لبنك الدم والأقرب)',
                hintText: profile.city.isEmpty ? null : profile.city,
              ),
            ),
            FilledButton(
              onPressed: () async {
                await profiles.update((p) => p.city = _city.text.trim());
                await store.mutate(
                  profile.profileId,
                  (b) => b.lastKnownCity = _city.text.trim(),
                );
              },
              child: const Text('حفظ المدينة'),
            ),
            SwitchListTile(
              title: const Text('ضغط مزدوج اختياري لمسار الطوارئ'),
              subtitle: const Text('تختار أنت. ليس تجسساً على الأزرار.'),
              value: bag?.doublePressEmergency ?? false,
              onChanged: (v) =>
                  store.mutate(profile.profileId, (b) => b.doublePressEmergency = v),
            ),
            const Divider(),
            const Text('هاتف ضائع (متوافق مع المتجر)'),
            TextField(
              controller: _pin,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'رمز أين جوالي'),
            ),
            OutlinedButton(
              onPressed: () async {
                await store.mutate(
                  profile.profileId,
                  (b) => b.lostPhonePin = _pin.text.trim(),
                );
                setState(() => _lostStatus = 'حُفظ الرمز محلياً.');
              },
              child: const Text('حفظ الرمز'),
            ),
            OutlinedButton(
              onPressed: () {
                final ok = LostPhonePolicy().pinMatches(
                  bag?.lostPhonePin ?? '',
                  _pin.text,
                );
                setState(() {
                  _lostStatus = ok
                      ? 'الرمز صحيح. المدينة المحفوظة: ${bag?.lastKnownCity.isEmpty ?? true ? 'غير مسجّلة' : bag!.lastKnownCity}'
                      : 'الرمز غير مطابق.';
                });
              },
              child: const Text('تجربة أين جوالي + الرمز'),
            ),
            if (_lostStatus.isNotEmpty) Text(_lostStatus),
          ],
          const Divider(),
          ListTile(
            title: const Text('ملفات العائلة على هذا الهاتف'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const FamilyScreen()),
              );
            },
          ),
          const Divider(),
          const Text(AppConstants.ownershipStatement),
          const Text(AppConstants.supportEmail),
          Text('الإصدار ${AppConstants.appVersion}'),
          const SizedBox(height: 8),
          const Text(AppConstants.medicalDisclaimer),
        ],
      ),
    );
  }
}
