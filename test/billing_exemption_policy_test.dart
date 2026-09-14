import 'package:flutter_test/flutter_test.dart';
import 'package:lifex_ai/features/finance/billing.dart';
import 'package:lifex_ai/features/profile/health_profile.dart';

void main() {
  test('المعتمد من ذوي الهمم يُعفى قبل أي بوابة', () {
    final policy = BillingExemptionPolicy();
    final profile = HealthProfile(
      profileId: 'p1',
      accreditedDisability: true,
    );
    expect(policy.evaluate(profile).isExempt, isTrue);
  });

  test('حساب عادي غير معفى', () {
    final policy = BillingExemptionPolicy();
    final profile = HealthProfile(profileId: 'p2');
    expect(policy.evaluate(profile).isExempt, isFalse);
  });
}
