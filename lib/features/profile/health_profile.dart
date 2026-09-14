class HealthProfile {
  HealthProfile({
    required this.profileId,
    this.legalName = '',
    this.alias = '',
    this.phone = '',
    this.email = '',
    this.ageYears,
    this.sex = '',
    this.heightCm,
    this.weightKg,
    this.bloodType = '',
    this.nationalId = '',
    this.photoAssetPath,
    this.accreditedDisability = false,
    this.chronicAccredited = false,
    this.bloodAlertsOptIn = false,
    this.maritalStatus = '',
    Map<String, String>? fields,
  }) : fields = fields ?? {};

  final String profileId;
  String legalName;
  String alias;
  String phone;
  String email;
  int? ageYears;
  String sex;
  double? heightCm;
  double? weightKg;
  String bloodType;
  String nationalId;
  String? photoAssetPath;
  bool accreditedDisability;
  bool chronicAccredited;
  bool bloodAlertsOptIn;
  String maritalStatus;
  final Map<String, String> fields;

  bool get hasRequiredPhoto =>
      photoAssetPath != null && photoAssetPath!.isNotEmpty;

  bool get feeExempt => accreditedDisability || chronicAccredited;

  String displayNameForCare() =>
      legalName.trim().isEmpty ? 'ملف صحي' : legalName.trim();

  String displayNamePublic() {
    final nick = alias.trim();
    if (nick.isNotEmpty) return nick;
    return displayNameForCare();
  }

  Map<String, dynamic> toJson() => {
        'profileId': profileId,
        'legalName': legalName,
        'alias': alias,
        'phone': phone,
        'email': email,
        'ageYears': ageYears,
        'sex': sex,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'bloodType': bloodType,
        'nationalId': nationalId,
        'photoAssetPath': photoAssetPath,
        'accreditedDisability': accreditedDisability,
        'chronicAccredited': chronicAccredited,
        'bloodAlertsOptIn': bloodAlertsOptIn,
        'maritalStatus': maritalStatus,
        'fields': fields,
      };

  factory HealthProfile.fromJson(Map<String, dynamic> json) {
    return HealthProfile(
      profileId: json['profileId'] as String,
      legalName: json['legalName'] as String? ?? '',
      alias: json['alias'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      ageYears: json['ageYears'] as int?,
      sex: json['sex'] as String? ?? '',
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      bloodType: json['bloodType'] as String? ?? '',
      nationalId: json['nationalId'] as String? ?? '',
      photoAssetPath: json['photoAssetPath'] as String?,
      accreditedDisability: json['accreditedDisability'] as bool? ?? false,
      chronicAccredited: json['chronicAccredited'] as bool? ?? false,
      bloodAlertsOptIn: json['bloodAlertsOptIn'] as bool? ?? false,
      maritalStatus: json['maritalStatus'] as String? ?? '',
      fields: Map<String, String>.from(
        (json['fields'] as Map?)?.map(
              (k, v) => MapEntry(k.toString(), v.toString()),
            ) ??
            {},
      ),
    );
  }
}
