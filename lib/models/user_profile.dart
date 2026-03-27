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
  final normalized = value?.toString().trim().toLowerCase();
  switch (normalized) {
    case 'male':
    case 'man':
    case 'm':
    case '0':
    case 'мужской':
    case 'мужчина':
      return UserGender.male;
    case 'female':
    case 'woman':
    case 'f':
    case '1':
    case 'женский':
    case 'женщина':
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
    // Some legacy documents may store profile data in a nested "profile" map.
    final source = json['profile'] is Map<String, dynamic>
        ? (json['profile'] as Map<String, dynamic>)
        : json;

    final rawGender = _asString(source['gender']) ?? _asString(source['sex']);

    return UserProfileData(
      name: (_asString(source['name']) ??
              _asString(source['userName']) ??
              _asString(source['username']) ??
              _asString(source['displayName']) ??
              '')
          .trim(),
      gender: userGenderFromStorage(rawGender),
      heightCm: _toDouble(source['heightCm'] ?? source['height']),
      weightKg: _toDouble(source['weightKg'] ?? source['weight']),
      photoBase64:
          _asString(source['photoBase64']) ?? _asString(source['photoUrl']),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final normalized = value
          .replaceAll(',', '.')
          .replaceAll(RegExp('[^0-9.+-]'), '');
      return double.tryParse(normalized);
    }
    return null;
  }

  static String? _asString(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    final stringValue = value.toString();
    return stringValue.trim().isEmpty ? null : stringValue;
  }
}
