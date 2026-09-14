import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
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
  String? _photoPath;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _alias.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إذن الصورة الشخصية'),
        content: const Text(
          'الصورة إلزامية للسيرة. تُستخدم للرعاية على هذا الجهاز. ليست مراقبة للآخرين.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('لاحقاً'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('موافق والتقاط'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.camera);
      if (file != null) {
        setState(() => _photoPath = file.path);
      }
    } catch (_) {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file != null) {
        setState(() => _photoPath = file.path);
      }
    }
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
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _pickPhoto,
            child: Text(
              _photoPath == null ? 'التقاط الصورة الإلزامية' : 'تم حفظ مسار الصورة',
            ),
          ),
          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
          FilledButton(
            onPressed: () async {
              if (_name.text.trim().isEmpty || _photoPath == null) {
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
                p.photoAssetPath = _photoPath;
              });
              if (!context.mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
              );
            },
            child: const Text('حفظ ودخول اللوحة'),
          ),
          const SizedBox(height: 12),
          const Text(AppConstants.medicalDisclaimer),
        ],
      ),
    );
  }
}
