import 'dart:math';

import '../../core/care_store.dart';

class GeoDistance {
  const GeoDistance();

  double kmBetween({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const earthKm = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return 2 * earthKm * atan2(sqrt(a), sqrt(1 - a));
  }

  double _rad(double deg) => deg * pi / 180;
}

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

  void applyUserLocation(
    List<SavedDoctor> doctors, {
    required double userLat,
    required double userLng,
  }) {
    const geo = GeoDistance();
    for (final doc in doctors) {
      if (doc.lat == null || doc.lng == null) continue;
      doc.km = geo.kmBetween(
        lat1: userLat,
        lon1: userLng,
        lat2: doc.lat!,
        lon2: doc.lng!,
      );
    }
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
