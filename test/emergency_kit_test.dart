import 'package:flutter_test/flutter_test.dart';
import 'package:lifex_ai/core/app_constants.dart';
import 'package:lifex_ai/features/emergency/emergency_kit.dart';

void main() {
  test('مؤشر قلبي حرج دون إرسال تلقائي في النص', () {
    final r = RiskLevelEngine().assess({'triggerType': 'cardiac_symptom'});
    expect(r.level, AppConstants.riskCritical);
    expect(r.reasonAr, contains('أكّد'));
  });

  test('سياق فارغ منخفض', () {
    final r = RiskLevelEngine().assess({});
    expect(r.level, AppConstants.riskLow);
  });

  test('حد عشرة أرقام', () {
    final registry = EmergencyPhoneContactsRegistry();
    for (var i = 0; i < 10; i++) {
      expect(
        registry.addContact(profileId: 'p', phoneNumber: '09$i').success,
        isTrue,
      );
    }
    expect(
      registry.addContact(profileId: 'p', phoneNumber: '099').success,
      isFalse,
    );
  });
}
