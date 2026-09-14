class LostPhonePolicy {
  static const String farSmsKeyword = 'أين جوالي';

  bool pinMatches(String storedPin, String input) =>
      storedPin.isNotEmpty && storedPin == input.trim();

  String nearbyActionAr() =>
      'قريب: رسالة أنا هنا + إنذار صوتي ظاهر. بلا تصوير من يمسك الهاتف.';

  String farSmsTemplate(String pinHint) =>
      '$farSmsKeyword ثم الرمز. إن صح: موقع تقريبي محفوظ، توفير طاقة، صامت، إطفاء الشاشة، تشغيل بيانات/GPS إن أذن المستخدم مسبقاً.';

  String simChangeWithoutPinAr() =>
      'تغيير الشريحة بلا الرمز ينبّه النسخة الاحتياطية وعشرة أرقام موثوقة. ليس قفلاً خفياً للجهاز.';
}
