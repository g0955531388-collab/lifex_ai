import '../../core/care_store.dart';

class DoctorDirectory {
  static const specialtiesAr = [
    'طب أسرة',
    'باطنة',
    'قلب',
    'أطفال',
    'نساء وتوليد',
    'جراحة',
    'عظام',
    'أذن أنف حنجرة',
    'عيون',
    'جلدية',
    'نفسية',
    'أسنان',
    'طوارئ',
  ];

  List<SavedDoctor> nearestFirst(List<SavedDoctor> doctors, {String? specialty}) {
    final filtered = specialty == null || specialty.isEmpty
        ? [...doctors]
        : doctors.where((d) => d.specialtyAr == specialty).toList();
    filtered.sort((a, b) => a.km.compareTo(b.km));
    return filtered;
  }
}

class PharmacyLocator {
  List<PharmacyStockItem> nearestWithDrug({
    required List<PharmacyStockItem> stock,
    required String query,
    required String city,
  }) {
    final q = query.trim();
    final inCity = stock.where((item) {
      final sameCity = city.trim().isEmpty ||
          item.city.trim().isEmpty ||
          item.city.trim() == city.trim();
      if (!sameCity) return false;
      if (q.isEmpty) return item.quantity > 0;
      return item.quantity > 0 &&
          (item.nameAr.contains(q) || item.barcode == q);
    }).toList()
      ..sort((a, b) => a.km.compareTo(b.km));
    return inCity;
  }
}
