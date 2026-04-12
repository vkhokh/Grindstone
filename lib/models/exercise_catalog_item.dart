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
}