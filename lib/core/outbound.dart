import 'package:url_launcher/url_launcher.dart';

class Outbound {
  static Future<bool> dial(String phone) {
    final uri = Uri(scheme: 'tel', path: phone.trim());
    return launchUrl(uri);
  }

  static Future<bool> sms(String phone, String body) {
    final uri = Uri(
      scheme: 'sms',
      path: phone.trim(),
      queryParameters: {'body': body},
    );
    return launchUrl(uri);
  }

  static Future<bool> whatsApp(String phone, String text) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse(
      'https://wa.me/$digits?text=${Uri.encodeComponent(text)}',
    );
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
