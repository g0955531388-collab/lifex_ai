class CycleEngine {
  static const int pregnancyDays = 280;

  DateTime? dueDateFromLmp(DateTime lmp) =>
      lmp.add(const Duration(days: pregnancyDays));

  int? pregnancyWeek(DateTime lmp, [DateTime? now]) {
    final today = now ?? DateTime.now();
    final days = today.difference(lmp).inDays;
    if (days < 0) return null;
    final week = (days ~/ 7) + 1;
    if (week > 42) return 42;
    return week;
  }

  int? cycleLengthDays(List<DateTime> starts) {
    if (starts.length < 2) return null;
    final ordered = [...starts]..sort();
    var sum = 0;
    for (var i = 1; i < ordered.length; i++) {
      sum += ordered[i].difference(ordered[i - 1]).inDays;
    }
    return sum ~/ (ordered.length - 1);
  }
}
