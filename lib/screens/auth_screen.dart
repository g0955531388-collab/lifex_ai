import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../core/outbound.dart';
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

  Future<void> _send(AuthController auth, String channel) async {
    if (_phone.text.trim().isEmpty || _email.text.trim().isEmpty) {
      setState(() => _error = 'الهاتف والبريد إلزاميان قبل إرسال الرمز.');
      return;
    }
    final code = auth.issueLocalOtp();
    final body = 'رمز Lifex-AI: $code';
    setState(() => _error = 'أُصدر الرمز عبر القناة الرسمية التي اخترتها.');
    if (channel == 'sms') {
      await Outbound.sms(_phone.text, body);
    } else if (channel == 'wa') {
      await Outbound.whatsApp(_phone.text, body);
    } else {
      await Outbound.email(_email.text, 'رمز Lifex-AI', body);
    }
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
            'الهاتف والبريد إلزاميان. الرمز عبر SMS أو واتساب أو البريد من قنواتك الرسمية. التطبيق لا يقرأ كل الرسائل.',
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => _send(auth, 'sms'),
                child: const Text('رمز SMS'),
              ),
              OutlinedButton(
                onPressed: () => _send(auth, 'wa'),
                child: const Text('رمز واتساب'),
              ),
              OutlinedButton(
                onPressed: () => _send(auth, 'email'),
                child: const Text('رمز البريد'),
              ),
            ],
          ),
          TextField(
            controller: _code,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'رمز التحقق'),
          ),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: AppConstants.brandTeal)),
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
