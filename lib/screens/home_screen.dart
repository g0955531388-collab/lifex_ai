import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../core/trial_manager.dart';
import '../features/profile/multi_profile_engine.dart';
import '../features/units/unit_catalog.dart';
import '../widgets/branding.dart';
import 'ai_screen.dart';
import 'blood_screen.dart';
import 'camera_screen.dart';
import 'chat_screen.dart';
import 'cv_screen.dart';
import 'dental_screen.dart';
import 'doctor_public_screen.dart';
import 'donate_screen.dart';
import 'emergency_screen.dart';
import 'family_screen.dart';
import 'hospital_screen.dart';
import 'meds_screen.dart';
import 'order_unit_screens.dart';
import 'pharmacy_screen.dart';
import 'questionnaire_screen.dart';
import 'radar_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'unit_screen.dart';
import 'wallet_screen.dart';
import 'women_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, CareUnit unit) {
    final trial = context.read<TrialManager>();
    final profile = context.read<ActiveProfileController>().profile;
    final allowed = const SessionAccessPolicy().canOpenUnit(
      unit.id,
      expired: trial.emergencyAndBloodOnly,
      feeExempt: profile?.feeExempt ?? false,
    );
    if (!allowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('انتهت التجربة: الطوارئ والدم الاختياري والمحفظة فقط حتى الاشتراك.'),
        ),
      );
      return;
    }
    final Widget page = switch (unit.id) {
      'cv' => const CvScreen(),
      'meds' => const MedsScreen(),
      'survey' => const QuestionnaireScreen(),
      'doctors' => const DoctorPublicScreen(),
      'labs' => const LabScreen(),
      'imaging' => const ImagingScreen(),
      'pharmacy' => const PharmacyScreen(),
      'hospital' => const HospitalScreen(),
      'dental' => const DentalScreen(),
      'blood' => const BloodScreen(),
      'donate' => const DonateScreen(),
      'women' => const WomenScreen(),
      'access' => const SpecialNeedsScreen(),
      'camera' => const CameraScreen(),
      'radar' => const RadarScreen(),
      'wallet' => const WalletScreen(),
      'reports' => const ReportsScreen(),
      'ai' => const AiScreen(),
      'chat' => const ChatScreen(),
      'family' => const FamilyScreen(),
      _ => UnitScreen(unit: unit),
    };
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final trial = context.read<TrialManager>();
    final profile = context.watch<ActiveProfileController>().profile;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppConstants.brandNavy,
        appBar: AppBar(
          backgroundColor: AppConstants.brandNavy,
          title: const Text('Lifex-AI'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
                );
              },
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
                );
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        body: Column(
          children: [
            if (trial.emergencyAndBloodOnly)
              const Material(
                color: Color(0xFF4E342E),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'انتهت التجربة: الطوارئ وتنبيه الدم الاختياري فقط حتى الاشتراك.',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'أهلاً ${profile?.displayNameForCare() ?? ''}',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            const Material(
              color: Color(0xFF12355F),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  'شريط إرشاد: حلّل ووجّه إلى مختص. لا تشخيص قاطع ولا وصفة من Lifex. الإعلانات على الصفحات العامة فقط.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.15,
                ),
                itemCount: kCareUnits.length,
                itemBuilder: (context, index) {
                  final unit = kCareUnits[index];
                  return Material(
                    color: const Color(0xFF163A68),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => _open(context, unit),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              unit.titleAr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              unit.subtitleAr,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            EmergencyBar(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const EmergencyScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
