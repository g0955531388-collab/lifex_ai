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
        ],
      ),
    );
  }
}

class SpecialNeedsScreen extends StatelessWidget {
  const SpecialNeedsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ActiveProfileController>();
    final p = controller.profile;
    return Scaffold(
      appBar: AppBar(title: const Text('ذوو الهمم والأمراض المزمنة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'بعد مطابقة السيرة وبطاقة الإعاقة أو المرض المزمن المعتمدة: رسوم Lifex صفر. الخصم من الوحدة اختياري ولا يُعرض مسبقاً.',
          ),
          SwitchListTile(
            title: const Text('عضو معتمد — إعاقة'),
            value: p?.accreditedDisability ?? false,
            onChanged: p == null
                ? null
                : (v) => controller.update((x) => x.accreditedDisability = v),
          ),
          SwitchListTile(
            title: const Text('عضو معتمد — مرض مزمن'),
            value: p?.chronicAccredited ?? false,
            onChanged: p == null
                ? null
                : (v) => controller.update((x) => x.chronicAccredited = v),
          ),
          if (p?.feeExempt ?? false)
            const Text('هذا الحساب مُعفى من رسوم اشتراك Lifex.'),
        ],
      ),
    );
  }
}
