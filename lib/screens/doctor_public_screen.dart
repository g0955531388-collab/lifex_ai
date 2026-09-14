import 'package:flutter/material.dart';

class DoctorPublicScreen extends StatefulWidget {
  const DoctorPublicScreen({super.key});

  @override
  State<DoctorPublicScreen> createState() => _DoctorPublicScreenState();
}

class _DoctorPublicScreenState extends State<DoctorPublicScreen> {
  bool accredited = false;
  bool following = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('صفحة الطبيب العامة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'قالب فارغ. الاسم والاختصاص والعنوان يملؤها حساب الطبيب الحقيقي. الجدول أدناه بلا أسماء مرضى.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          const Text('الطبيب', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF008080))),
          const Text('الاختصاص: —'),
          const Text('العنوان: —'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              FilledButton(
                onPressed: () => setState(() => accredited = !accredited),
                child: Text(accredited ? 'طبيبي المعتمد' : 'اعتماد هذا الطبيب'),
              ),
              OutlinedButton(
                onPressed: () => setState(() => following = !following),
                child: Text(following ? 'تتابع' : 'متابعة'),
              ),
            ],
          ),
          if (accredited)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('سيُخطر الطبيب ويُفتح له الوصول إلى سيرتك بعد التأكيد.'),
            ),
          const SizedBox(height: 16),
          const Text('مواعيد اليوم (شاغر / محجوز بلا اسم)'),
          Wrap(
            spacing: 8,
            children: const [
              _Slot(label: '09:00 ص', free: true),
              _Slot(label: '10:00 ص', free: false),
              _Slot(label: '11:00 ص', free: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({required this.label, required this.free});
  final String label;
  final bool free;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(free ? '$label شاغر' : '$label محجوز'),
      backgroundColor: free ? const Color(0xFFE0F2F1) : const Color(0xFFB0BEC5),
    );
  }
}
