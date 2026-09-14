import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceFillButton extends StatelessWidget {
  const VoiceFillButton({super.key, required this.onText});

  final void Function(String text) onText;

  Future<void> _listen(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إذن الميكروفون'),
        content: const Text(
          'لملء الحقل بالصوت وأنت تضغط. ليس تجسساً في الخلفية ولا قراءة رسائل.',
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
    if (ok != true) return;
    final speech = SpeechToText();
    final ready = await speech.initialize();
    if (!ready) {
      onText('');
      return;
    }
    await speech.listen(
      localeId: 'ar_SA',
      onResult: (result) {
        if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
          onText(result.recognizedWords.trim());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'ملء بالصوت',
      onPressed: () => _listen(context),
      icon: const Icon(Icons.mic),
    );
  }
}
