enum UserGender { male, female }

extension UserGenderX on UserGender {
  String get storageValue {
    switch (this) {
      case UserGender.male:
        return 'male';
      case UserGender.female:
        return 'female';
    }
  }

  String get label {
    switch (this) {
      case UserGender.male:
        return 'Мужской';
      case UserGender.female:
        return 'Женский';
    }
  }
}

UserGender? userGenderFromStorage(String? value) {
  switch (value) {
    case 'male':
      return UserGender.male;
    case 'female':
      return UserGender.female;
    default:
      return null;
  }
}

class UserProfileData {
  const UserProfileData({
    required this.name,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    this.photoBase64,
  });

  final String name;
  final UserGender? gender;
  final double? heightCm;
  final double? weightKg;
  // Optional base64-encoded avatar stored in Firestore.
  final String? photoBase64;

  const UserProfileData.empty()
    : name = '',
      gender = null,
      heightCm = null,
      weightKg = null,
      photoBase64 = null;

  bool get isComplete {
    return name.trim().isNotEmpty &&
        gender != null &&
        heightCm != null &&
        weightKg != null;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'gender': gender?.storageValue,
      'heightCm': heightCm,
      'weightKg': weightKg,
    };

    if (photoBase64 != null) {
      map['photoBase64'] = photoBase64;
    }

    return map;
  }

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      name: (json['name'] as String? ?? '').trim(),
      gender: userGenderFromStorage(json['gender'] as String?),
      heightCm: _toDouble(json['heightCm']),
      weightKg: _toDouble(json['weightKg']),
      photoBase64: json['photoBase64'] as String? ?? json['photoUrl'] as String?,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.'));
    }
    return null;
  }
}

