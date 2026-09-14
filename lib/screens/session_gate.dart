import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/auth_controller.dart';
import '../features/profile/multi_profile_engine.dart';
import 'attribution_screen.dart';
import 'home_screen.dart';
import 'profile_setup_screen.dart';

class SessionGate extends StatelessWidget {
  const SessionGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final profiles = context.watch<ActiveProfileController>();
    if (auth.isVerified && profiles.hasAnyProfile) {
      return const HomeScreen();
    }
    if (auth.isVerified) {
      return const ProfileSetupScreen();
    }
    return const AttributionScreen();
  }
}
