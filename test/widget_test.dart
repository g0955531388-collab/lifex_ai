import 'package:flutter_test/flutter_test.dart';
import 'package:lifex_ai/core/app_constants.dart';

void main() {
  test('هوية التطبيق الرسمية', () {
    expect(AppConstants.packageName, 'lifex_ai');
    expect(AppConstants.supportEmail, 'g0955531388@gmail.com');
    expect(AppConstants.splashSeconds, 5);
  });
}
