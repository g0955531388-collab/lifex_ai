import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/auth_controller.dart';
import '../features/profile/multi_profile_engine.dart';
import 'home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _name = TextEditingController();
  final _alias = TextEditingController();
  bool _photoMarked = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _alias.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('السيرة الصحية — قالب فارغ')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'املأ بالصوت أو الكتابة لاحقاً. الكاميرا تقرأ الأوراق عند تفعيلها بموافقة. الصورة الشخصية إلزامية.',
          ),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'الاسم الحقيقي للرعاية والدواء'),
          ),
          TextField(
            controller: _alias,
            decoration: const InputDecoration(labelText: 'اسم مستعار للعامة (اختياري)'),
          ),
          SwitchListTile(
            title: const Text('أضفت صورة شخصية (إلزامية)'),
            subtitle: const Text('في الإطلاق تُلتقط من الكاميرا بعد شرح الإذن.'),
            value: _photoMarked,
            onChanged: (v) => setState(() => _photoMarked = v),
          ),
          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
          FilledButton(
            onPressed: () async {
              if (_name.text.trim().isEmpty || !_photoMarked) {
                setState(() => _error = 'الاسم الحقيقي والصورة إلزاميان.');
                return;
              }
              final auth = context.read<AuthController>();
              final profiles = context.read<ActiveProfileController>();
              await profiles.createInitial(
                legalName: _name.text.trim(),
                phone: auth.phone,
                email: auth.email,
              );
              await profiles.update((p) {
                p.alias = _alias.text.trim();
                p.photoAssetPath = 'local://portrait';
              });
              if (!context.mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
              );
            },
            child: const Text('حفظ ودخول اللوحة'),
          ),
        ],
      ),
    );
  }
}
