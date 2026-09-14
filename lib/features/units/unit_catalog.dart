class CareUnit {
  const CareUnit({
    required this.id,
    required this.titleAr,
    required this.subtitleAr,
    required this.route,
  });

  final String id;
  final String titleAr;
  final String subtitleAr;
  final String route;
}

const List<CareUnit> kCareUnits = [
  CareUnit(
    id: 'cv',
    titleAr: 'السيرة الصحية',
    subtitleAr: 'ملف فارغ يُملأ بالصوت أو الكتابة أو الكاميرا',
    route: '/cv',
  ),
  CareUnit(
    id: 'meds',
    titleAr: 'الأدوية',
    subtitleAr: 'جدول الوصفة · نطق الاسم الحقيقي',
    route: '/meds',
  ),
  CareUnit(
    id: 'ai',
    titleAr: 'المساعد المحلي',
    subtitleAr: 'سيرة + JSON · الويب بأمرك فقط',
    route: '/ai',
  ),
  CareUnit(
    id: 'chat',
    titleAr: 'محادثة Lifex',
    subtitleAr: 'تقارير وملفات كبيرة',
    route: '/chat',
  ),
  CareUnit(
    id: 'family',
    titleAr: 'العائلة',
    subtitleAr: 'ملفات مرتبطة · بلا دمج',
    route: '/family',
  ),
  CareUnit(
    id: 'survey',
    titleAr: 'الاستبيان الصحي',
    subtitleAr: 'مسودة للطبيب لا تشخيصاً',
    route: '/survey',
  ),
  CareUnit(
    id: 'doctors',
    titleAr: 'الأطباء',
    subtitleAr: 'معتمد أو متابعة · جدول بلا أسماء',
    route: '/doctors',
  ),
  CareUnit(
    id: 'labs',
    titleAr: 'المخابر',
    subtitleAr: 'طلب إلكتروني ثم نتيجة للطبيب',
    route: '/unit',
  ),
  CareUnit(
    id: 'imaging',
    titleAr: 'الأشعة',
    subtitleAr: 'أرشيف المريض · ليست قراءة إشعاعية',
    route: '/unit',
  ),
  CareUnit(
    id: 'pharmacy',
    titleAr: 'الصيدلية',
    subtitleAr: 'أقرب دواء من المخزون ثم تحضير',
    route: '/unit',
  ),
  CareUnit(
    id: 'hospital',
    titleAr: 'المستشفى',
    subtitleAr: 'حلقة تُعبأ في السيرة · إحصاء داخلي',
    route: '/unit',
  ),
  CareUnit(
    id: 'dental',
    titleAr: 'الأسنان',
    subtitleAr: 'جدول على مستوى السن',
    route: '/unit',
  ),
  CareUnit(
    id: 'blood',
    titleAr: 'بنك الدم',
    subtitleAr: 'نفس المدينة · تنبيه اختياري',
    route: '/blood',
  ),
  CareUnit(
    id: 'donate',
    titleAr: 'التبرعات',
    subtitleAr: 'بموافقة المستفيد · بلا عمولة',
    route: '/unit',
  ),
  CareUnit(
    id: 'women',
    titleAr: 'صحة المرأة',
    subtitleAr: 'دورة وحمل · خصوصية الملف',
    route: '/unit',
  ),
  CareUnit(
    id: 'access',
    titleAr: 'ذوو الهمم',
    subtitleAr: 'اعتماد ثم رسوم Lifex صفر',
    route: '/access',
  ),
  CareUnit(
    id: 'camera',
    titleAr: 'الكاميرا الذكية',
    subtitleAr: 'أوراق وشاشات وعلامات كإشارات',
    route: '/unit',
  ),
  CareUnit(
    id: 'radar',
    titleAr: 'الرادار الضوئي',
    subtitleAr: 'فلاش ظاهر · ليس سلاحاً',
    route: '/unit',
  ),
  CareUnit(
    id: 'wallet',
    titleAr: 'المحفظة والاشتراك',
    subtitleAr: 'متجر أولاً · إعفاء المعتمدين',
    route: '/wallet',
  ),
  CareUnit(
    id: 'reports',
    titleAr: 'التقارير',
    subtitleAr: 'نص للطباعة أو الإرسال',
    route: '/reports',
  ),
];
