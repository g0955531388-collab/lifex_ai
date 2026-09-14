import '../../core/app_constants.dart';

class EmergencyPhoneContact {
  EmergencyPhoneContact({required this.phoneNumber, DateTime? addedAt})
      : addedAt = addedAt ?? DateTime.now();

  final String phoneNumber;
  final DateTime addedAt;
}

class EmergencyContactActionResult {
  const EmergencyContactActionResult._(this.success, this.messageAr);
  factory EmergencyContactActionResult.ok(String messageAr) =>
      EmergencyContactActionResult._(true, messageAr);
  factory EmergencyContactActionResult.rejected(String messageAr) =>
      EmergencyContactActionResult._(false, messageAr);

  final bool success;
  final String messageAr;
}

class EmergencyPhoneContactsRegistry {
  final Map<String, List<EmergencyPhoneContact>> _byProfile = {};

  List<EmergencyPhoneContact> contactsFor(String profileId) =>
      List.unmodifiable(_byProfile[profileId] ?? const []);

  EmergencyContactActionResult addContact({
    required String profileId,
    required String phoneNumber,
  }) {
    final normalized = phoneNumber.trim();
    if (normalized.isEmpty) {
      return EmergencyContactActionResult.rejected('رقم الهاتف غير صالح.');
    }
    final existing = _byProfile.putIfAbsent(profileId, () => []);
    if (existing.any((c) => c.phoneNumber == normalized)) {
      return EmergencyContactActionResult.rejected('هذا الرقم مضاف بالفعل.');
    }
    if (existing.length >= AppConstants.maxEmergencyPhoneContacts) {
      return EmergencyContactActionResult.rejected(
        'وصلت للحد الأقصى (${AppConstants.maxEmergencyPhoneContacts} أرقام).',
      );
    }
    existing.add(EmergencyPhoneContact(phoneNumber: normalized));
    return EmergencyContactActionResult.ok('تمت إضافة الرقم.');
  }

  EmergencyContactActionResult removeContact({
    required String profileId,
    required String phoneNumber,
  }) {
    final existing = _byProfile[profileId];
    if (existing == null ||
        !existing.any((c) => c.phoneNumber == phoneNumber)) {
      return EmergencyContactActionResult.rejected('هذا الرقم غير موجود.');
    }
    existing.removeWhere((c) => c.phoneNumber == phoneNumber);
    return EmergencyContactActionResult.ok('تم حذف الرقم.');
  }
}

class RiskAssessment {
  const RiskAssessment({required this.level, required this.reasonAr});
  final String level;
  final String reasonAr;
}

class RiskLevelEngine {
  RiskAssessment assess(Map<String, dynamic> context) {
    final triggerType = context['triggerType'] as String?;
    final hasChronic = context['hasChronicCondition'] as bool? ?? false;
    final age = context['age'] as int?;
    const critical = [
      'cardiac_symptom',
      'respiratory_distress',
      'severe_bleeding',
      'loss_of_consciousness',
    ];
    if (triggerType != null && critical.contains(triggerType)) {
      return const RiskAssessment(
        level: AppConstants.riskCritical,
        reasonAr: 'مؤشر يستدعي انتباهاً فورياً. أكّد قبل إرسال الاستغاثة.',
      );
    }
    if (hasChronic && (age == null || age >= 60)) {
      return const RiskAssessment(
        level: AppConstants.riskHigh,
        reasonAr: 'حالة مزمنة مع عامل عمري — إشارة حذر لا إرسالاً تلقائياً.',
      );
    }
    if (triggerType != null) {
      return const RiskAssessment(
        level: AppConstants.riskMedium,
        reasonAr: 'مؤشر يستدعي متابعة قريبة.',
      );
    }
    return const RiskAssessment(
      level: AppConstants.riskLow,
      reasonAr: 'لا مؤشرات كافية لتصنيف خطير.',
    );
  }
}
