import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../core/health_event_manager.dart';
import '../features/profile/multi_profile_engine.dart';

class DonateScreen extends StatelessWidget {
  const DonateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profiles = context.watch<ActiveProfileController>();
    final mine = profiles.profile;
    final listed = profiles.all.where((p) => p.donationListed).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('التبرعات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'المتبرع يرى فقط من وافق على الإدراج. عمولة المنصة صفر. بعد التأكيد: وصلني التبرع ثم شكر.',
          ),
          SwitchListTile(
            title: const Text('أدرج هذا الملف للمتبرعين الموافقين'),
            value: mine?.donationListed ?? false,
            onChanged: mine == null
                ? null
                : (v) => profiles.update((p) => p.donationListed = v),
          ),
          const Divider(),
          if (listed.isEmpty)
            const Text('لا ملفات مدرجة على هذا الجهاز.')
          else
            for (final p in listed)
              ListTile(
                title: Text(p.displayNamePublic()),
                subtitle: const Text('اسم عام فقط'),
                trailing: OutlinedButton(
                  onPressed: () {
                    HealthEventManager.instance.emitQuick(
                      HealthEventType.donationMatched,
                      sourceModule: 'donate_screen',
                      profileId: p.profileId,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('وصلني التبرع. شكراً.')),
                    );
                  },
                  child: const Text('وصلني التبرع'),
                ),
              ),
          const Text(AppConstants.medicalDisclaimer),
        ],
      ),
    );
  }
}
