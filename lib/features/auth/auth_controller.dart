import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._prefs);

  final SharedPreferences _prefs;
  static const _keyPhone = 'lifex_auth_phone';
  static const _keyEmail = 'lifex_auth_email';
  static const _keyVerified = 'lifex_auth_verified';

  String phone = '';
  String email = '';
  String? lastDevCode;
  bool get isVerified => _prefs.getBool(_keyVerified) ?? false;

  void load() {
    phone = _prefs.getString(_keyPhone) ?? '';
    email = _prefs.getString(_keyEmail) ?? '';
    notifyListeners();
  }

  String issueLocalOtp() {
    lastDevCode =
        (100000 + DateTime.now().millisecond % 900000).toString().padLeft(6, '0');
    notifyListeners();
    return lastDevCode!;
  }

  Future<bool> verify({
    required String phoneInput,
    required String emailInput,
    required String code,
  }) async {
    if (phoneInput.trim().isEmpty || emailInput.trim().isEmpty) {
      return false;
    }
    if (code != lastDevCode) return false;
    phone = phoneInput.trim();
    email = emailInput.trim();
    await _prefs.setString(_keyPhone, phone);
    await _prefs.setString(_keyEmail, email);
    await _prefs.setBool(_keyVerified, true);
    notifyListeners();
    return true;
  }
}
