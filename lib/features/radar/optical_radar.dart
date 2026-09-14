class OpticalRadarEstimate {
  const OpticalRadarEstimate({
    required this.meters,
    required this.methodAr,
  });

  final double meters;
  final String methodAr;
}

class OpticalRadar {
  const OpticalRadar();

  OpticalRadarEstimate fromSteps({
    required int steps,
    required double stepLengthMeters,
  }) {
    final length = stepLengthMeters <= 0 ? 0.7 : stepLengthMeters;
    final count = steps < 0 ? 0 : steps;
    return OpticalRadarEstimate(
      meters: count * length,
      methodAr:
          'تقدير بالمعايرة على الجهاز (خطوات × طول الخطوة). فلاش ظاهر. ليس سلاحاً.',
    );
  }

  OpticalRadarEstimate fromCalibration({
    required double referenceMeters,
    required double referenceLevel,
    required double currentLevel,
  }) {
    if (referenceMeters <= 0 || referenceLevel <= 0 || currentLevel <= 0) {
      return const OpticalRadarEstimate(
        meters: 0,
        methodAr: 'المعايرة غير مكتملة. قِف على مسافة معلومة ثم أعد المحاولة.',
      );
    }
    return OpticalRadarEstimate(
      meters: referenceMeters * (referenceLevel / currentLevel),
      methodAr:
          'تقدير نسبي بعد معايرة المسافة المعلومة. على الجهاز فقط. ليس راداراً عسكرياً.',
    );
  }

  bool get freeForeverForAccredited => true;
}
