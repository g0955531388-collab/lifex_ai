import 'package:flutter/material.dart';

import '../core/app_constants.dart';
import '../widgets/branding.dart';
import 'auth_screen.dart';

class AttributionScreen extends StatelessWidget {
  const AttributionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.brandNavy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SealImage(size: 140),
              const SizedBox(height: 20),
              Text(
                AppConstants.ownershipStatement,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.6),
              ),
              const SizedBox(height: 12),
              const Text(
                'المساعدة: ${AppConstants.assistant}\n${AppConstants.supportEmail}\n${AppConstants.academyLabel}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, height: 1.5),
              ),
              const Spacer(),
              Text(
                AppConstants.medicalDisclaimer,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(builder: (_) => const AuthScreen()),
                  );
                },
                child: const Text('متابعة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
