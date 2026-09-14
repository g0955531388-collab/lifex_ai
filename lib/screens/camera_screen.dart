import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../core/care_store.dart';
import '../core/local_knowledge.dart';
import '../features/profile/multi_profile_engine.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final _note = TextEditingController();
  String _kind = 'document';
  String _status = '';

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _capture(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إذن الكاميرا'),
        content: const Text(
          'لالتقاط أوراق أو شاشات أو منطقة جسم بموافقتك الظاهرة. لا تصوير خفي لمن يمسك الهاتف.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('رفض'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final file = await ImagePicker().pickImage(source: ImageSource.camera);
    if (file == null || !context.mounted) return;
    final profile = context.read<ActiveProfileController>().profile;
    if (profile == null) return;
    await context.read<CareStore>().mutate(profile.profileId, (bag) {
      bag.cameraNotes.add(
        CameraNote(
          id: newCareId(),
          kind: _kind,
          path: file.path,
          noteAr: _note.text.trim(),
        ),
      );
    });
    setState(() {
      _status =
          'حُفظ المسار. قراءة OCR الآلية فارغة حتى ربط مسار الملف ومحرك معتمد. العلامات أدناه إشارات لا تشخيص.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ActiveProfileController>().profile;
    final store = context.watch<CareStore>();
    final signs = context.read<LocalKnowledge>().cameraSigns;
    final notes = profile == null
        ? const <CameraNote>[]
        : store.bag(profile.profileId).cameraNotes;
    return Scaffold(
      appBar: AppBar(title: const Text('الكاميرا الذكية')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'أوراق، تقارير، أدوية، تخطيط، أختام وتواريخ. عدّاد نقطة وريد بعد معايرة. شاشة جهاز بعد إذن.',
          ),
          DropdownButton<String>(
            value: _kind,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'document', child: Text('ورقة / تقرير')),
              DropdownMenuItem(value: 'body', child: Text('منطقة من الجسم')),
              DropdownMenuItem(value: 'monitor', child: Text('شاشة جهاز')),
              DropdownMenuItem(value: 'iv', child: Text('نقطة وريد — بعد معايرة')),
            ],
            onChanged: (v) => setState(() => _kind = v ?? 'document'),
          ),
          TextField(
            controller: _note,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'ما تقرأه أو تصفه'),
          ),
          FilledButton(
            onPressed: () => _capture(context),
            child: const Text('التقاط ظاهر بعد الموافقة'),
          ),
          if (_status.isNotEmpty) Text(_status),
          const Divider(),
          const Text('علامات مرجعية (إشارة للمختص)'),
          for (final sign in signs)
            ListTile(
              title: Text('${sign['sign']}'),
              subtitle: Text('${sign['meaning']}'),
            ),
          const Divider(),
          for (final note in notes)
            ListTile(
              title: Text(note.kind),
              subtitle: Text(
                note.noteAr.isEmpty ? note.path : '${note.noteAr}\n${note.path}',
              ),
            ),
          const Text(AppConstants.medicalDisclaimer),
        ],
      ),
    );
  }
}
