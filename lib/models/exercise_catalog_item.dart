enum ExerciseTrackingType {
  weightReps,
  bodyweightReps,
  duration,
}

class ExerciseCatalogItem {
  final String id;
  final String name;
  final String muscleGroup;
  final String equipment;
  final List<String> aliases;
  final bool isCustom;
  final ExerciseTrackingType trackingType;

  const ExerciseCatalogItem({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    required this.trackingType,
    this.aliases = const [],
    this.isCustom = false,
  });

  bool matchesQuery(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;

    final fields = <String>[
      name,
      muscleGroup,
      equipment,
      ...aliases,
    ];

    return fields.any(
      (field) => field.toLowerCase().contains(normalizedQuery),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'muscleGroup': muscleGroup,
      'equipment': equipment,
      'aliases': aliases,
      'isCustom': isCustom,
      'trackingType': trackingType.name,
    };
  }

  factory ExerciseCatalogItem.fromJson(Map<String, dynamic> json) {
    return ExerciseCatalogItem(
      id: json['id'] as String,
      name: json['name'] as String,
      muscleGroup: json['muscleGroup'] as String? ?? 'Другое',
      equipment: json['equipment'] as String? ?? 'Не указано',
      aliases: (json['aliases'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      isCustom: json['isCustom'] as bool? ?? false,
      trackingType: ExerciseTrackingType.values.firstWhere(
        (e) => e.name == json['trackingType'],
        orElse: () => ExerciseTrackingType.weightReps,
      ),
    );
  }
}