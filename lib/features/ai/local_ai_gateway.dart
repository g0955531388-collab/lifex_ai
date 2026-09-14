import '../../core/app_constants.dart';
import '../../core/local_knowledge.dart';
import '../profile/health_profile.dart';

class AiReply {
  const AiReply({
    required this.textAr,
    required this.usedWeb,
  });

  final String textAr;
  final bool usedWeb;
}

class LocalAiGateway {
  LocalAiGateway(this.knowledge);

  final LocalKnowledge knowledge;

  static bool requestsWeb(String question) {
    final q = question.trim().toLowerCase();
    return q.contains('search the web') ||
        q.contains('ابحث في الويب') ||
        q.contains('ابحث بالويب');
  }

  AiReply answer({
    required String question,
    HealthProfile? profile,
  }) {
    if (question.trim().isEmpty) {
      return const AiReply(
        textAr: 'اكتب سؤالاً صحياً. الإجابة من السيرة والمرجع المحلي فقط.',
        usedWeb: false,
      );
    }
    if (requestsWeb(question)) {
      return const AiReply(
        textAr:
            'البحث في الويب لا يعمل تلقائياً. إن أردت مصدراً خارجياً الصقه هنا بعد قراءته. '
            'حتى ذلك الحين الجواب من السيرة والملفات المحلية فقط.',
        usedWeb: false,
      );
    }
    final hits = knowledge.search(question);
    final buffer = StringBuffer()
      ..writeln(AppConstants.medicalDisclaimer)
      ..writeln();
    if (profile != null) {
      buffer.writeln('الملف النشط: ${profile.displayNameForCare()}');
      if (profile.bloodType.isNotEmpty) {
        buffer.writeln('الفصيلة: ${profile.bloodType}');
      }
      if (profile.allergies.isNotEmpty) {
        buffer.writeln('حساسيات مسجّلة: ${profile.allergies.join('، ')}');
      }
      if (profile.pregnant) {
        buffer.writeln('الحمل مفعّل على هذا الملف فقط.');
      }
      buffer.writeln();
    }
    if (hits.isEmpty) {
      buffer.writeln(
        'لا بند مطابق في المرجع المحلي. وسّع السؤال أو أرفق ورقة عبر الكاميرا. ليست موسوعة كل الأمراض.',
      );
    } else {
      buffer.writeln('إشارات من المرجع المحلي:');
      for (final hit in hits.take(8)) {
        buffer.writeln('- ${hit.kindAr}: ${hit.titleAr} — ${hit.detailAr}');
      }
    }
    buffer
      ..writeln()
      ..writeln(knowledge.disclaimerAr);
    return AiReply(textAr: buffer.toString(), usedWeb: false);
  }
}
