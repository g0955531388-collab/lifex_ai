import 'package:flutter/material.dart';

import '../core/app_constants.dart';

class SealImage extends StatelessWidget {
  const SealImage({super.key, this.size = 180});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'ختم Lifex-AI الرسمي: دماغ وعصا الطب وكرسي متحرك وقلب',
      image: true,
      child: ClipOval(
        child: Image.asset(
          'assets/branding/lifex_seal.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              width: size,
              height: size,
              color: AppConstants.brandNavy,
              alignment: Alignment.center,
              child: const Text(
                'LIFEX-AI',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            );
          },
        ),
      ),
    );
  }
}

class EmergencyBar extends StatelessWidget {
  const EmergencyBar({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB71C1C)),
            onPressed: onPressed,
            child: const Text('طوارئ'),
          ),
        ),
      ),
    );
  }
}
