import '../profile/health_profile.dart';

class GeneticsSignal {
  const GeneticsSignal({
    required this.messageAr,
    required this.profileIds,
  });

  final String messageAr;
  final List<String> profileIds;
}

class GeneticsSignalEngine {
  List<GeneticsSignal> estimate(List<HealthProfile> optedIn) {
    if (optedIn.length < 2) {
      return const [];
    }
    final signals = <GeneticsSignal>[];
    final byBlood = <String, List<HealthProfile>>{};
    for (final p in optedIn) {
      final type = p.bloodType.trim();
      if (type.isEmpty) continue;
      byBlood.putIfAbsent(type, () => []).add(p);
    }
    for (final entry in byBlood.entries) {
      if (entry.value.length < 2) continue;
      signals.add(
        GeneticsSignal(
          messageAr:
              'نمط فصيلة تقديري مشترك (${entry.key}) بين ملفات وافقت. ليس تشخيصاً ولا دمج ملفات.',
          profileIds: entry.value.map((p) => p.profileId).toList(),
        ),
      );
    }
    final chronic = optedIn.where((p) => p.chronicAccredited).toList();
    if (chronic.length >= 2) {
      signals.add(
        GeneticsSignal(
          messageAr:
              'أكثر من ملف مرتبط سجّل اعتماد مرض مزمن. تنبيه للعضو والطبيب المعتمد فقط. لا قائمة عامة.',
          profileIds: chronic.map((p) => p.profileId).toList(),
        ),
      );
    }
    if (signals.isEmpty) {
      signals.add(
        GeneticsSignal(
          messageAr:
              'لا نمط كافٍ بعد. التقدير يحتاج ملفات مرتبطة موافِقة دون دمج السير.',
          profileIds: optedIn.map((p) => p.profileId).toList(),
        ),
      );
    }
    return signals;
  }
}
