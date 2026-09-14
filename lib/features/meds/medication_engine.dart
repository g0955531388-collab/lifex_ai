import '../profile/health_profile.dart';

class DoseSafetyResult {
  const DoseSafetyResult({
    required this.mayTakeNow,
    required this.messageAr,
  });

  final bool mayTakeNow;
  final String messageAr;
}

class MedicationEngine {
  DoseSafetyResult crossCheck({
    required String drugName,
    required HealthProfile profile,
  }) {
    final drug = drugName.trim();
    if (drug.isEmpty) {
      return const DoseSafetyResult(
        mayTakeNow: false,
        messageAr: 'اسم الدواء القانوني كما وصفه الطبيب مطلوب.',
      );
    }
    final lower = drug.toLowerCase();
    final allergyHit = profile.allergies.any((a) {
      final t = a.trim();
      return t.isNotEmpty &&
          (lower.contains(t.toLowerCase()) || t.contains(drug));
    });
    if (allergyHit) {
      return const DoseSafetyResult(
        mayTakeNow: false,
        messageAr:
            'إشارة تعارض مع حساسية في السيرة. لا تتناول حتى يؤكد الطبيب.',
      );
    }
    final nsaid = lower.contains('ibuprofen') || drug.contains('إيبوبروفين');
    if (profile.pregnant && nsaid) {
      return const DoseSafetyResult(
        mayTakeNow: false,
        messageAr:
            'إشارة حذر مع الحمل لهذا الصنف. لا تتناول حتى يؤكد طبيبك.',
      );
    }
    return DoseSafetyResult(
      mayTakeNow: true,
      messageAr:
          'تذكير حسب الوصفة فقط لـ ${profile.displayNameForCare()}. ليست وصفة جديدة.',
    );
  }

  String spokenDose({
    required HealthProfile profile,
    required String doseText,
  }) {
    return '${profile.displayNameForCare()}، حان موعد $doseText';
  }

  bool isDueAt(List<String> timesAr, DateTime now) {
    for (final raw in timesAr) {
      final match = RegExp(r'(\d{1,2})').firstMatch(raw.trim());
      if (match == null) continue;
      if (int.tryParse(match.group(1)!) == now.hour) return true;
    }
    return false;
  }
}
