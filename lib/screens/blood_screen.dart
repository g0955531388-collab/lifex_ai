import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/profile/multi_profile_engine.dart';

class BloodScreen extends StatelessWidget {
  const BloodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ActiveProfileController>();
    final p = controller.profile;
    return Scaffold(
      appBar: AppBar(title: const Text('بنك الدم')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'نفس المدينة فقط. الفصائل تُعلن. الكميات داخلية للوحدة. الدم لا يُباع ولا عمولة للمنصة. التنبيه مغلق حتى تفعّله.',
          ),
          SwitchListTile(
            title: const Text('قبول تنبيهات الدم'),
            value: p?.bloodAlertsOptIn ?? false,
            onChanged: p == null
                ? null
                : (v) => controller.update((profile) => profile.bloodAlertsOptIn = v),
          ),
          Text('الفصيلة في سيرتك: ${p?.bloodType.isEmpty ?? true ? 'غير مذكورة' : p!.bloodType}'),
          Text('المدينة: ${p?.city.isEmpty ?? true ? 'غير مذكورة' : p!.city}'),
        ],
      ),
    );
  }
}
