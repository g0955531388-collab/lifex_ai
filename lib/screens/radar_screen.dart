import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:torch_light/torch_light.dart';

import '../core/app_constants.dart';
import '../core/care_store.dart';
import '../features/profile/multi_profile_engine.dart';
import '../features/radar/optical_radar.dart';

class RadarScreen extends StatefulWidget {
  const RadarScreen({super.key});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> {
  final _steps = TextEditingController(text: '4');
  final _radar = const OpticalRadar();
  bool _pulsing = false;
  String _status = '';
  Timer? _timer;
  bool _flashOn = false;

  @override
  void dispose() {
    _timer?.cancel();
    _steps.dispose();
    _stopTorch();
    super.dispose();
  }

  Future<void> _stopTorch() async {
    try {
      await TorchLight.disableTorch();
    } catch (_) {}
  }

  Future<void> _pulse(BuildContext context) async {
    final profile = context.read<ActiveProfileController>().profile;
    if (profile == null) return;
    setState(() {
      _pulsing = true;
      _status = 'فلاش ظاهر يعمل. ليس سلاحاً.';
    });
    HapticFeedback.heavyImpact();
    var ticks = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 400), (t) async {
      ticks++;
      _flashOn = !_flashOn;
      try {
        if (_flashOn) {
          await TorchLight.enableTorch();
        } else {
          await TorchLight.disableTorch();
        }
      } catch (_) {}
      if (mounted) setState(() {});
      if (ticks >= 8) {
        t.cancel();
        await _stopTorch();
        if (mounted) {
          setState(() {
            _pulsing = false;
            _flashOn = false;
          });
        }
      }
    });
    final store = context.read<CareStore>();
    final bag = store.bag(profile.profileId);
    final estimate = _radar.fromSteps(
      steps: int.tryParse(_steps.text) ?? 0,
      stepLengthMeters: bag.stepLengthMeters,
    );
    setState(() => _status = '${estimate.methodAr}\nحوالي ${estimate.meters.toStringAsFixed(1)} م');
    try {
      await FlutterTts().speak('المسافة التقريبية ${estimate.meters.toStringAsFixed(1)} متر');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ActiveProfileController>().profile;
    final free = profile?.feeExempt == true && _radar.freeForeverForAccredited;
    return Scaffold(
      appBar: AppBar(title: const Text('الرادار الضوئي')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 120,
            color: _flashOn ? Colors.white : AppConstants.brandNavy,
            alignment: Alignment.center,
            child: Text(
              _pulsing ? 'فلاش يعمل' : 'فلاش متوقف',
              style: TextStyle(
                color: _flashOn ? Colors.black : Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'نبض ضوء الهاتف ظاهر على الشاشة. تقدير المسافة على الجهاز بعد معايرة الخطوة. مجاني دائماً للمعتمدين من ذوي الهمم وخصوصاً المكفوفين وللمزمنين المعتمدين.',
          ),
          if (free)
            const Text(
              'هذا الحساب معتمد: الرادار الضوئي مجاني دائماً.',
              style: TextStyle(color: AppConstants.brandTeal),
            ),
          TextField(
            controller: _steps,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'عدد الخطوات للهدف'),
          ),
          FilledButton(
            onPressed: _pulsing ? null : () => _pulse(context),
            child: const Text('نبض ظاهر + نطق المسافة'),
          ),
          if (_status.isNotEmpty) Text(_status),
          const Text(AppConstants.medicalDisclaimer),
        ],
      ),
    );
  }
}
