import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../features/profile/multi_profile_engine.dart';
import '../features/units/unit_catalog.dart';

class UnitScreen extends StatelessWidget {
  const UnitScreen({super.key, required this.unit});

  final CareUnit unit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(unit.titleAr)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(unit.subtitleAr, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            const Text(
              'قالب فارغ بلا أسماء تجريبية. يُملأ من حساب الوحدة الحقيقي بعد الاشتراك والصلاحية.',
            ),
            const Spacer(),
            const Text(AppConstants.medicalDisclaimer),
          ],
        ),
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String q = '';

  @override
  Widget build(BuildContext context) {
    final hits = kCareUnits
        .where((u) => u.titleAr.contains(q) || u.subtitleAr.contains(q) || q.isEmpty)
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('بحث صحي داخل الشبكة')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(labelText: 'ابحث في وحدات Lifex'),
              onChanged: (v) => setState(() => q = v.trim()),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                for (final u in hits)
                  ListTile(title: Text(u.titleAr), subtitle: Text(u.subtitleAr)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SpecialNeedsScreen extends StatelessWidget {
  const SpecialNeedsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profiles = context.watch<ActiveProfileController>();
    final profile = profiles.profile;
    return Scaffold(
      appBar: AppBar(title: const Text('ذوو الهمم والأمراض المزمنة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'الاعتماد بعد السيرة وبطاقة الإعاقة أو المرض المزمن في بلدك. '
            'رسوم Lifex تصبح صفراً. الخصم لدى الوحدة اختياري ولا يُعرض مسبقاً.',
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('أنا عضو معتمد (إعاقة)'),
            value: profile?.accreditedDisability ?? false,
            onChanged: profile == null
                ? null
                : (v) => profiles.update((p) => p.accreditedDisability = v),
          ),
          SwitchListTile(
            title: const Text('أنا عضو معتمد (مرض مزمن)'),
            value: profile?.chronicAccredited ?? false,
            onChanged: profile == null
                ? null
                : (v) => profiles.update((p) => p.chronicAccredited = v),
          ),
          const SizedBox(height: 8),
          Text(
            profile != null && profile.feeExempt
                ? 'هذا الحساب مُعفى من رسوم Lifex.'
                : 'لم يُعتمد الإعفاء بعد.',
          ),
          const SizedBox(height: 12),
          const Text(AppConstants.medicalDisclaimer),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('الأذونات: شرح ثم موافقة ثم إدارة هنا. كاميرا وميكروفون وموقع عند الحاجة فقط.'),
          SizedBox(height: 8),
          Text(AppConstants.ownershipStatement),
          Text(AppConstants.supportEmail),
          SizedBox(height: 8),
          Text(AppConstants.medicalDisclaimer),
        ],
      ),
    );
  }
}
