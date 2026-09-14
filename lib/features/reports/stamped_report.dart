import '../../core/app_constants.dart';
import '../profile/health_profile.dart';

class StampedReport {
  StampedReport({
    required this.profile,
    required this.bodyAr,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final HealthProfile profile;
  final String bodyAr;
  final DateTime createdAt;

  String get reportId =>
      'LIFEX-${createdAt.millisecondsSinceEpoch}';

  String toPlainText() {
    final buffer = StringBuffer()
      ..writeln('===== ${AppConstants.appName} =====')
      ..writeln(AppConstants.ownershipStatement)
      ..writeln('البريد: ${AppConstants.supportEmail}')
      ..writeln('رقم التقرير: $reportId')
      ..writeln('التاريخ: ${createdAt.toIso8601String()}')
      ..writeln()
      ..writeln('الملف: ${profile.displayNameForCare()}')
      ..writeln('الهاتف: ${profile.phone}')
      ..writeln('البريد: ${profile.email}')
      ..writeln()
      ..writeln(bodyAr)
      ..writeln()
      ..writeln(AppConstants.medicalDisclaimer)
      ..writeln(
        'هذا المستند من المنصة وليس سجل المنشأة الرسمية إلا إذا أصدرته الوحدة نفسها.',
      );
    return buffer.toString();
  }
}
