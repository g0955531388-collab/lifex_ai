import 'package:flutter_test/flutter_test.dart';
import 'package:lifex_ai/core/care_store.dart';
import 'package:lifex_ai/core/local_knowledge.dart';
import 'package:lifex_ai/features/ai/local_ai_gateway.dart';
import 'package:lifex_ai/features/dental/dental_chart.dart';
import 'package:lifex_ai/features/doctors/doctor_directory.dart';
import 'package:lifex_ai/features/family/genetics_signal.dart';
import 'package:lifex_ai/features/lost_phone/lost_phone_policy.dart';
import 'package:lifex_ai/features/meds/medication_engine.dart';
import 'package:lifex_ai/features/profile/health_profile.dart';
import 'package:lifex_ai/features/radar/optical_radar.dart';
import 'package:lifex_ai/features/women/cycle_engine.dart';

void main() {
  test('حساسية الدواء تمنع التناول حتى تأكيد الطبيب', () {
    final profile = HealthProfile(
      profileId: 'p',
      legalName: 'ملف',
      allergies: ['إيبوبروفين'],
    );
    final r = MedicationEngine().crossCheck(
      drugName: 'إيبوبروفين',
      profile: profile,
    );
    expect(r.mayTakeNow, isFalse);
    expect(r.messageAr, contains('حساسية'));
  });

  test('نطق الجرعة بالاسم الحقيقي', () {
    final profile = HealthProfile(profileId: 'p', legalName: 'غازي');
    expect(
      MedicationEngine().spokenDose(profile: profile, doseText: 'حبّة صباحاً'),
      contains('غازي'),
    );
  });

  test('المساعد لا يبحث في الويب إلا بالعبارة', () {
    expect(LocalAiGateway.requestsWeb('ابحث في الويب عن الربو'), isTrue);
    final knowledge = LocalKnowledge(
      diseases: [
        {'nameAr': 'الربو', 'nameEn': 'Asthma', 'bodySystem': 'respiratory'},
      ],
      medications: const [],
      symptoms: const [],
      tests: const [],
      cameraSigns: const [],
      disclaimerAr: 'توعية',
    );
    final reply = LocalAiGateway(knowledge).answer(question: 'ابحث في الويب عن الربو');
    expect(reply.usedWeb, isFalse);
    expect(reply.textAr, contains('لا يعمل تلقائياً'));
  });

  test('الرادار يقدّر بالمعايرة', () {
    final e = const OpticalRadar().fromSteps(steps: 10, stepLengthMeters: 0.7);
    expect(e.meters, closeTo(7, 0.01));
  });

  test('جدول الأسنان 32 سناً', () {
    expect(DentalChart.fdiAdult, hasLength(32));
    final chart = DentalChart();
    chart.setNote(11, 'حشوة');
    expect(chart.noteFor(11), 'حشوة');
  });

  test('أقرب صيدلية أولاً في نفس المدينة', () {
    final hits = PharmacyLocator().nearestWithDrug(
      stock: [
        PharmacyStockItem(
          id: '1',
          nameAr: 'باراسيتامول',
          city: 'جدة',
          km: 8,
          quantity: 2,
        ),
        PharmacyStockItem(
          id: '2',
          nameAr: 'باراسيتامول',
          city: 'جدة',
          km: 1,
          quantity: 5,
        ),
      ],
      query: 'باراسيتامول',
      city: 'جدة',
    );
    expect(hits.first.id, '2');
  });

  test('حمل أربعون أسبوعاً من آخر دورة', () {
    final lmp = DateTime(2026, 1, 1);
    expect(CycleEngine().dueDateFromLmp(lmp), DateTime(2026, 10, 8));
  });

  test('أنماط عائلية بلا دمج', () {
    final signals = GeneticsSignalEngine().estimate([
      HealthProfile(profileId: 'a', bloodType: 'A+', geneticsOptIn: true),
      HealthProfile(profileId: 'b', bloodType: 'A+', geneticsOptIn: true),
    ]);
    expect(signals.first.messageAr, contains('تقديري'));
    expect(signals.first.messageAr, contains('دمج'));
  });

  test('هاتف ضائع بلا تصوير خفي', () {
    final p = LostPhonePolicy();
    expect(p.pinMatches('1234', '1234'), isTrue);
    expect(p.nearbyActionAr(), contains('بلا تصوير'));
    expect(LostPhonePolicy.farSmsKeyword, 'أين جوالي');
  });
}
