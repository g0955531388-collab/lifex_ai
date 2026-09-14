import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrescribedMedication {
  PrescribedMedication({
    required this.id,
    required this.legalDrugName,
    required this.doseText,
    this.timesAr = const [],
    this.barcode = '',
  });

  final String id;
  String legalDrugName;
  String doseText;
  List<String> timesAr;
  String barcode;

  Map<String, dynamic> toJson() => {
        'id': id,
        'legalDrugName': legalDrugName,
        'doseText': doseText,
        'timesAr': timesAr,
        'barcode': barcode,
      };

  factory PrescribedMedication.fromJson(Map<String, dynamic> json) {
    return PrescribedMedication(
      id: json['id'] as String,
      legalDrugName: json['legalDrugName'] as String? ?? '',
      doseText: json['doseText'] as String? ?? '',
      timesAr: List<String>.from(json['timesAr'] as List? ?? const []),
      barcode: json['barcode'] as String? ?? '',
    );
  }
}

class CareOrder {
  CareOrder({
    required this.id,
    required this.unitType,
    required this.summaryAr,
    this.status = 'requested',
    this.resultAr = '',
  });

  final String id;
  final String unitType;
  String summaryAr;
  String status;
  String resultAr;

  Map<String, dynamic> toJson() => {
        'id': id,
        'unitType': unitType,
        'summaryAr': summaryAr,
        'status': status,
        'resultAr': resultAr,
      };

  factory CareOrder.fromJson(Map<String, dynamic> json) {
    return CareOrder(
      id: json['id'] as String,
      unitType: json['unitType'] as String,
      summaryAr: json['summaryAr'] as String? ?? '',
      status: json['status'] as String? ?? 'requested',
      resultAr: json['resultAr'] as String? ?? '',
    );
  }
}

class HospitalEpisode {
  HospitalEpisode({
    required this.id,
    required this.summaryAr,
    this.packedIntoCv = true,
  });

  final String id;
  String summaryAr;
  bool packedIntoCv;

  Map<String, dynamic> toJson() => {
        'id': id,
        'summaryAr': summaryAr,
        'packedIntoCv': packedIntoCv,
      };

  factory HospitalEpisode.fromJson(Map<String, dynamic> json) {
    return HospitalEpisode(
      id: json['id'] as String,
      summaryAr: json['summaryAr'] as String? ?? '',
      packedIntoCv: json['packedIntoCv'] as bool? ?? true,
    );
  }
}

class SavedDoctor {
  SavedDoctor({
    required this.id,
    required this.specialtyAr,
    this.displayName = '',
    this.city = '',
    this.address = '',
    this.phone = '',
    this.km = 0,
    this.accredited = false,
    this.following = false,
  });

  final String id;
  String specialtyAr;
  String displayName;
  String city;
  String address;
  String phone;
  double km;
  bool accredited;
  bool following;

  Map<String, dynamic> toJson() => {
        'id': id,
        'specialtyAr': specialtyAr,
        'displayName': displayName,
        'city': city,
        'address': address,
        'phone': phone,
        'km': km,
        'accredited': accredited,
        'following': following,
      };

  factory SavedDoctor.fromJson(Map<String, dynamic> json) {
    return SavedDoctor(
      id: json['id'] as String,
      specialtyAr: json['specialtyAr'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      city: json['city'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      km: (json['km'] as num?)?.toDouble() ?? 0,
      accredited: json['accredited'] as bool? ?? false,
      following: json['following'] as bool? ?? false,
    );
  }
}

class PharmacyStockItem {
  PharmacyStockItem({
    required this.id,
    required this.nameAr,
    this.barcode = '',
    this.city = '',
    this.km = 0,
    this.quantity = 0,
  });

  final String id;
  String nameAr;
  String barcode;
  String city;
  double km;
  int quantity;

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameAr': nameAr,
        'barcode': barcode,
        'city': city,
        'km': km,
        'quantity': quantity,
      };

  factory PharmacyStockItem.fromJson(Map<String, dynamic> json) {
    return PharmacyStockItem(
      id: json['id'] as String,
      nameAr: json['nameAr'] as String? ?? '',
      barcode: json['barcode'] as String? ?? '',
      city: json['city'] as String? ?? '',
      km: (json['km'] as num?)?.toDouble() ?? 0,
      quantity: json['quantity'] as int? ?? 0,
    );
  }
}

class CameraNote {
  CameraNote({
    required this.id,
    required this.kind,
    this.path = '',
    this.noteAr = '',
  });

  final String id;
  final String kind;
  String path;
  String noteAr;

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind,
        'path': path,
        'noteAr': noteAr,
      };

  factory CameraNote.fromJson(Map<String, dynamic> json) {
    return CameraNote(
      id: json['id'] as String,
      kind: json['kind'] as String? ?? 'document',
      path: json['path'] as String? ?? '',
      noteAr: json['noteAr'] as String? ?? '',
    );
  }
}

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.bodyAr,
    this.fromSelf = true,
  });

  final String id;
  String bodyAr;
  bool fromSelf;

  Map<String, dynamic> toJson() => {
        'id': id,
        'bodyAr': bodyAr,
        'fromSelf': fromSelf,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      bodyAr: json['bodyAr'] as String? ?? '',
      fromSelf: json['fromSelf'] as bool? ?? true,
    );
  }
}

class ProfileCareBag {
  ProfileCareBag({
    List<PrescribedMedication>? medications,
    Map<String, String>? dentalNotes,
    List<CareOrder>? orders,
    List<HospitalEpisode>? episodes,
    List<String>? cycleStartsIso,
    List<SavedDoctor>? doctors,
    List<PharmacyStockItem>? pharmacyStock,
    List<CameraNote>? cameraNotes,
    List<ChatMessage>? chat,
    List<String>? emergencyPhones,
    this.nextDentalVisit = '',
    this.pregnancyLmpIso = '',
    this.lostPhonePin = '',
    this.digitalEarOptIn = false,
    this.doublePressEmergency = false,
    this.radarCalibrationMeters = 1,
    this.stepLengthMeters = 0.7,
    this.lastKnownCity = '',
  })  : medications = medications ?? [],
        dentalNotes = dentalNotes ?? {},
        orders = orders ?? [],
        episodes = episodes ?? [],
        cycleStartsIso = cycleStartsIso ?? [],
        doctors = doctors ?? [],
        pharmacyStock = pharmacyStock ?? [],
        cameraNotes = cameraNotes ?? [],
        chat = chat ?? [],
        emergencyPhones = emergencyPhones ?? [];

  final List<PrescribedMedication> medications;
  final Map<String, String> dentalNotes;
  final List<CareOrder> orders;
  final List<HospitalEpisode> episodes;
  final List<String> cycleStartsIso;
  final List<SavedDoctor> doctors;
  final List<PharmacyStockItem> pharmacyStock;
  final List<CameraNote> cameraNotes;
  final List<ChatMessage> chat;
  final List<String> emergencyPhones;
  String nextDentalVisit;
  String pregnancyLmpIso;
  String lostPhonePin;
  bool digitalEarOptIn;
  bool doublePressEmergency;
  double radarCalibrationMeters;
  double stepLengthMeters;
  String lastKnownCity;

  Map<String, dynamic> toJson() => {
        'medications': medications.map((e) => e.toJson()).toList(),
        'dentalNotes': dentalNotes,
        'orders': orders.map((e) => e.toJson()).toList(),
        'episodes': episodes.map((e) => e.toJson()).toList(),
        'cycleStartsIso': cycleStartsIso,
        'doctors': doctors.map((e) => e.toJson()).toList(),
        'pharmacyStock': pharmacyStock.map((e) => e.toJson()).toList(),
        'cameraNotes': cameraNotes.map((e) => e.toJson()).toList(),
        'chat': chat.map((e) => e.toJson()).toList(),
        'emergencyPhones': emergencyPhones,
        'nextDentalVisit': nextDentalVisit,
        'pregnancyLmpIso': pregnancyLmpIso,
        'lostPhonePin': lostPhonePin,
        'digitalEarOptIn': digitalEarOptIn,
        'doublePressEmergency': doublePressEmergency,
        'radarCalibrationMeters': radarCalibrationMeters,
        'stepLengthMeters': stepLengthMeters,
        'lastKnownCity': lastKnownCity,
      };

  factory ProfileCareBag.fromJson(Map<String, dynamic> json) {
    return ProfileCareBag(
      medications: (json['medications'] as List? ?? const [])
          .map((e) => PrescribedMedication.fromJson(e as Map<String, dynamic>))
          .toList(),
      dentalNotes: Map<String, String>.from(
        (json['dentalNotes'] as Map?)?.map(
              (k, v) => MapEntry(k.toString(), v.toString()),
            ) ??
            {},
      ),
      orders: (json['orders'] as List? ?? const [])
          .map((e) => CareOrder.fromJson(e as Map<String, dynamic>))
          .toList(),
      episodes: (json['episodes'] as List? ?? const [])
          .map((e) => HospitalEpisode.fromJson(e as Map<String, dynamic>))
          .toList(),
      cycleStartsIso: List<String>.from(json['cycleStartsIso'] as List? ?? const []),
      doctors: (json['doctors'] as List? ?? const [])
          .map((e) => SavedDoctor.fromJson(e as Map<String, dynamic>))
          .toList(),
      pharmacyStock: (json['pharmacyStock'] as List? ?? const [])
          .map((e) => PharmacyStockItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      cameraNotes: (json['cameraNotes'] as List? ?? const [])
          .map((e) => CameraNote.fromJson(e as Map<String, dynamic>))
          .toList(),
      chat: (json['chat'] as List? ?? const [])
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      emergencyPhones:
          List<String>.from(json['emergencyPhones'] as List? ?? const []),
      nextDentalVisit: json['nextDentalVisit'] as String? ?? '',
      pregnancyLmpIso: json['pregnancyLmpIso'] as String? ?? '',
      lostPhonePin: json['lostPhonePin'] as String? ?? '',
      digitalEarOptIn: json['digitalEarOptIn'] as bool? ?? false,
      doublePressEmergency: json['doublePressEmergency'] as bool? ?? false,
      radarCalibrationMeters:
          (json['radarCalibrationMeters'] as num?)?.toDouble() ?? 1,
      stepLengthMeters: (json['stepLengthMeters'] as num?)?.toDouble() ?? 0.7,
      lastKnownCity: json['lastKnownCity'] as String? ?? '',
    );
  }
}

class CareStore extends ChangeNotifier {
  CareStore(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'lifex_care_store_v1';
  final Map<String, ProfileCareBag> _bags = {};

  Future<void> load() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    for (final entry in map.entries) {
      _bags[entry.key] =
          ProfileCareBag.fromJson(entry.value as Map<String, dynamic>);
    }
  }

  ProfileCareBag bag(String profileId) =>
      _bags.putIfAbsent(profileId, () => ProfileCareBag());

  Future<void> mutate(String profileId, void Function(ProfileCareBag bag) edit) async {
    final current = bag(profileId);
    edit(current);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final encoded = jsonEncode(
      _bags.map((key, value) => MapEntry(key, value.toJson())),
    );
    await _prefs.setString(_key, encoded);
  }
}

String newCareId() => DateTime.now().microsecondsSinceEpoch.toString();
