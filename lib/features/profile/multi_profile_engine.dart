import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_constants.dart';
import '../../core/health_event_manager.dart';
import 'health_profile.dart';

enum ProfileRole { primaryOwner, spouse, child, parent, otherRelative, dependent }

class FamilyProfileLink {
  FamilyProfileLink({
    required this.profileId,
    required this.role,
    this.hasIndependentLock = false,
  });

  final String profileId;
  final ProfileRole role;
  bool hasIndependentLock;
}

class MultiProfileEngine {
  MultiProfileEngine(this._prefs);

  final SharedPreferences _prefs;
  static const _keyProfiles = 'lifex_profiles_json';
  static const _keyActive = 'lifex_active_profile_id';

  final Map<String, HealthProfile> _profiles = {};
  String? _activeId;

  String? get activeProfileId => _activeId;
  HealthProfile? get active =>
      _activeId == null ? null : _profiles[_activeId];
  List<HealthProfile> get all => _profiles.values.toList();
  bool get hasAnyProfile => _profiles.isNotEmpty;

  Future<void> load() async {
    final raw = _prefs.getString(_keyProfiles);
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      for (final item in list) {
        final profile = HealthProfile.fromJson(item as Map<String, dynamic>);
        _profiles[profile.profileId] = profile;
      }
    }
    _activeId = _prefs.getString(_keyActive);
    if (_activeId == null && _profiles.isNotEmpty) {
      _activeId = _profiles.keys.first;
    }
  }

  Future<HealthProfile> createInitial({
    required String legalName,
    String phone = '',
    String email = '',
  }) async {
    if (_profiles.length >= AppConstants.maxHealthProfilesDefault) {
      throw StateError('بلغ الحد الأقصى للملفات الصحية.');
    }
    final id = 'p${DateTime.now().millisecondsSinceEpoch}';
    final profile = HealthProfile(
      profileId: id,
      legalName: legalName,
      phone: phone,
      email: email,
    );
    _profiles[id] = profile;
    _activeId = id;
    await _persist();
    HealthEventManager.instance.emitQuick(
      HealthEventType.profileUpdated,
      sourceModule: 'multi_profile_engine',
      profileId: id,
    );
    return profile;
  }

  Future<void> switchTo(String profileId) async {
    if (!_profiles.containsKey(profileId)) return;
    _activeId = profileId;
    await _prefs.setString(_keyActive, profileId);
  }

  Future<HealthProfile> createLinked({
    required String legalName,
    String phone = '',
    String email = '',
  }) async {
    if (_profiles.length >= AppConstants.maxHealthProfilesDefault) {
      throw StateError('بلغ الحد الأقصى للملفات الصحية.');
    }
    if (legalName.trim().isEmpty) {
      throw StateError('الاسم الحقيقي إلزامي للملف الجديد.');
    }
    final id = 'p${DateTime.now().millisecondsSinceEpoch}';
    final profile = HealthProfile(
      profileId: id,
      legalName: legalName.trim(),
      phone: phone,
      email: email,
    );
    _profiles[id] = profile;
    await _persist();
    HealthEventManager.instance.emitQuick(
      HealthEventType.profileUpdated,
      sourceModule: 'multi_profile_engine',
      profileId: id,
    );
    return profile;
  }

  Future<void> save(HealthProfile profile) async {
    _profiles[profile.profileId] = profile;
    await _persist();
    HealthEventManager.instance.emitQuick(
      HealthEventType.profileUpdated,
      sourceModule: 'multi_profile_engine',
      profileId: profile.profileId,
    );
  }

  Future<void> _persist() async {
    final encoded =
        jsonEncode(_profiles.values.map((p) => p.toJson()).toList());
    await _prefs.setString(_keyProfiles, encoded);
    if (_activeId != null) {
      await _prefs.setString(_keyActive, _activeId!);
    }
  }
}

class ActiveProfileController extends ChangeNotifier {
  ActiveProfileController(this.engine);

  final MultiProfileEngine engine;

  HealthProfile? get profile => engine.active;
  bool get hasAnyProfile => engine.hasAnyProfile;
  List<HealthProfile> get all => engine.all;

  Future<void> reload() async {
    await engine.load();
    notifyListeners();
  }

  Future<void> createInitial({
    required String legalName,
    String phone = '',
    String email = '',
  }) async {
    await engine.createInitial(
      legalName: legalName,
      phone: phone,
      email: email,
    );
    notifyListeners();
  }

  Future<void> update(void Function(HealthProfile p) edit) async {
    final current = engine.active;
    if (current == null) return;
    edit(current);
    await engine.save(current);
    notifyListeners();
  }

  Future<void> switchTo(String profileId) async {
    await engine.switchTo(profileId);
    notifyListeners();
  }

  Future<HealthProfile> createLinked({
    required String legalName,
    String phone = '',
    String email = '',
  }) async {
    final created = await engine.createLinked(
      legalName: legalName,
      phone: phone,
      email: email,
    );
    notifyListeners();
    return created;
  }
}
