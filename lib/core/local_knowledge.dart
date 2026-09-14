import 'dart:convert';

import 'package:flutter/services.dart';

class KnowledgeHit {
  const KnowledgeHit({
    required this.kindAr,
    required this.titleAr,
    required this.detailAr,
  });

  final String kindAr;
  final String titleAr;
  final String detailAr;
}

class LocalKnowledge {
  LocalKnowledge({
    required this.diseases,
    required this.medications,
    required this.symptoms,
    required this.tests,
    required this.cameraSigns,
    required this.disclaimerAr,
  });

  final List<Map<String, dynamic>> diseases;
  final List<Map<String, dynamic>> medications;
  final List<Map<String, dynamic>> symptoms;
  final List<Map<String, dynamic>> tests;
  final List<Map<String, dynamic>> cameraSigns;
  final String disclaimerAr;

  static Future<LocalKnowledge> load([AssetBundle? bundle]) async {
    final assets = bundle ?? rootBundle;
    final diseasesJson =
        jsonDecode(await assets.loadString('assets/data/diseases_database.json'))
            as Map<String, dynamic>;
    final medsJson = jsonDecode(
            await assets.loadString('assets/data/medications_database.json'))
        as Map<String, dynamic>;
    final symptomsJson =
        jsonDecode(await assets.loadString('assets/data/symptoms_database.json'))
            as Map<String, dynamic>;
    final testsJson =
        jsonDecode(await assets.loadString('assets/data/tests_database.json'))
            as Map<String, dynamic>;
    final signsRaw =
        jsonDecode(await assets.loadString('assets/data/camera_signs.json'));
    final signs = signsRaw is List
        ? signsRaw.cast<Map<String, dynamic>>()
        : List<Map<String, dynamic>>.from(
            (signsRaw as Map)['signs'] as List? ?? const [],
          );
    return LocalKnowledge(
      diseases: List<Map<String, dynamic>>.from(diseasesJson['diseases'] as List),
      medications:
          List<Map<String, dynamic>>.from(medsJson['medications'] as List),
      symptoms: List<Map<String, dynamic>>.from(symptomsJson['symptoms'] as List),
      tests: List<Map<String, dynamic>>.from(testsJson['tests'] as List),
      cameraSigns: signs,
      disclaimerAr: (diseasesJson['_meta'] as Map?)?['disclaimer_ar'] as String? ??
          'مرجع توعية فقط. ليس تشخيصاً.',
    );
  }

  List<KnowledgeHit> search(String query) {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final hits = <KnowledgeHit>[];
    void scan(List<Map<String, dynamic>> rows, String kind, List<String> keys) {
      for (final row in rows) {
        final blob = keys.map((k) => '${row[k] ?? ''}').join(' ');
        if (blob.contains(q)) {
          hits.add(
            KnowledgeHit(
              kindAr: kind,
              titleAr: (row['nameAr'] ?? row['sign'] ?? row['id']).toString(),
              detailAr: (row['meaning'] ??
                      row['nameEn'] ??
                      row['bodySystem'] ??
                      row['urgencyDefault'] ??
                      '')
                  .toString(),
            ),
          );
        }
      }
    }

    scan(diseases, 'حالة', ['nameAr', 'nameEn', 'bodySystem']);
    scan(medications, 'دواء', ['nameAr', 'nameEn']);
    scan(symptoms, 'عرض', ['nameAr']);
    scan(tests, 'تحليل', ['nameAr', 'nameEn']);
    scan(cameraSigns, 'علامة كاميرا', ['sign', 'meaning', 'area']);
    return hits;
  }
}
