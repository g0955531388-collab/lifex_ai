import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../features/finance/billing.dart';
import '../features/profile/multi_profile_engine.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ActiveProfileController>().profile;
    final exemption = profile == null
        ? const ExemptionDecision(isExempt: false)
        : BillingExemptionPolicy().evaluate(profile);
    return Scaffold(
      appBar: AppBar(title: const Text('المحفظة والاشتراك')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'مستخدم ${AppConstants.userSubscriptionUsd} دولار/سنة · '
            'وحدة ${AppConstants.unitSubscriptionUsd} · '
            'مستشفى ${AppConstants.hospitalSubscriptionUsd}. الدفع عبر المتجر أولاً. لا تُحفظ أرقام بطاقات هنا.',
          ),
          const SizedBox(height: 12),
          if (exemption.isExempt)
            Text(exemption.reasonAr ?? '')
          else
            const Text('15 يوماً كاملة ثم شهر مخفّض ثم اشتراك. الطوارئ تبقى.'),
        ],
      ),
    );
  }
}
