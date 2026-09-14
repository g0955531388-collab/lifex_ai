import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../features/auth/auth_controller.dart';
import 'profile_setup_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _code = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'الهاتف والبريد إلزاميان. رمز التحقق يصل عبر SMS أو واتساب في الإطلاق؛ هنا رمز تطوير محلي.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'رقم الهاتف'),
          ),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              final code = auth.issueLocalOtp();
              setState(() => _error = 'رمز التطوير: $code');
            },
            child: const Text('إرسال الرمز'),
          ),
          TextField(
            controller: _code,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'رمز التحقق'),
          ),
          if (_error != null) Text(_error!, style: const TextStyle(color: AppConstants.brandTeal)),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              final ok = await auth.verify(
                phoneInput: _phone.text,
                emailInput: _email.text,
                code: _code.text.trim(),
              );
              if (!ok) {
                setState(() => _error = 'أكمل الهاتف والبريد والرمز الصحيح.');
                return;
              }
              if (!context.mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const ProfileSetupScreen()),
              );
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}
