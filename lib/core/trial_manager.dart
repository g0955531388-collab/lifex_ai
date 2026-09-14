import 'package:shared_preferences/shared_preferences.dart';

import 'app_constants.dart';

enum TrialPhase { full, reduced, expired }

class TrialManager {
  TrialManager(this._prefs);

  final SharedPreferences _prefs;
  static const _keyInstalledAt = 'lifex_installed_at';

  DateTime get installedAt {
    final raw = _prefs.getString(_keyInstalledAt);
    if (raw == null) {
      final now = DateTime.now().toIso8601String();
      _prefs.setString(_keyInstalledAt, now);
      return DateTime.now();
    }
    return DateTime.tryParse(raw) ?? DateTime.now();
  }

  int get daysSinceInstall =>
      DateTime.now().difference(installedAt).inDays;

  TrialPhase get phase {
    if (daysSinceInstall < AppConstants.trialFullDays) {
      return TrialPhase.full;
    }
    if (daysSinceInstall <
        AppConstants.trialFullDays + AppConstants.trialReducedDays) {
      return TrialPhase.reduced;
    }
    return TrialPhase.expired;
  }

  bool get emergencyAndBloodOnly => phase == TrialPhase.expired;
}

class SessionAccessPolicy {
  const SessionAccessPolicy();

  bool canOpenUnit(
    String unitId, {
    required bool expired,
    required bool feeExempt,
  }) {
    if (!expired) return true;
    if (unitId == 'blood' || unitId == 'wallet') return true;
    if (unitId == 'radar' && feeExempt) return true;
    return false;
  }
}
