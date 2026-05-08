import 'package:cloud_firestore/cloud_firestore.dart';

import 'exercise_catalog_item.dart';

class WorkoutProgressOverview {
  const WorkoutProgressOverview({
    required this.totalTrainings,
    required this.totalExerciseSessions,
    required this.totalApproaches,
    required this.uniqueExercises,
    required this.totalVolumeKg,
    required this.totalDurationSeconds,
    this.lastCompletedAt,
    this.generatedAt,
  });

  const WorkoutProgressOverview.empty()
      : totalTrainings = 0,
        totalExerciseSessions = 0,
        totalApproaches = 0,
        uniqueExercises = 0,
        totalVolumeKg = 0,
        totalDurationSeconds = 0,
        lastCompletedAt = null,
        generatedAt = null;

  final int totalTrainings;
  final int totalExerciseSessions;
  final int totalApproaches;
  final int uniqueExercises;
  final double totalVolumeKg;
  final int totalDurationSeconds;
  final DateTime? lastCompletedAt;
  final DateTime? generatedAt;

  factory WorkoutProgressOverview.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    if (data == null) {
      return const WorkoutProgressOverview.empty();
    }

    return WorkoutProgressOverview(
      totalTrainings: data['totalTrainings'] as int? ?? 0,
      totalExerciseSessions: data['totalExerciseSessions'] as int? ?? 0,
      totalApproaches: data['totalApproaches'] as int? ?? 0,
      uniqueExercises: data['uniqueExercises'] as int? ?? 0,
      totalVolumeKg: (data['totalVolumeKg'] as num?)?.toDouble() ?? 0,
      totalDurationSeconds: data['totalDurationSeconds'] as int? ?? 0,
      lastCompletedAt: _timestampToDateTime(data['lastCompletedAt']),
      generatedAt: _timestampToDateTime(data['generatedAt']),
    );
  }
}

class ExerciseProgressSummary {
  const ExerciseProgressSummary({
    required this.exerciseKey,
    required this.exerciseName,
    required this.trackingType,
    required this.sessionCount,
    required this.approachCount,
    required this.personalBestValue,
    required this.totalVolumeKg,
    required this.totalDurationSeconds,
    required this.improvementValue,
    this.exerciseId,
    this.bestWeightKg,
    this.bestReps,
    this.bestAdditionalWeightKg,
    this.bestTotalLoadKg,
    this.bestDurationSeconds,
    this.firstPerformanceValue,
    this.latestPerformanceValue,
    this.improvementPercent,
    this.lastCompletedAt,
  });

  final String exerciseKey;
  final String? exerciseId;
  final String exerciseName;
  final ExerciseTrackingType trackingType;
  final int sessionCount;
  final int approachCount;
  final double personalBestValue;
  final double? bestWeightKg;
  final int? bestReps;
  final double? bestAdditionalWeightKg;
  final double? bestTotalLoadKg;
  final int? bestDurationSeconds;
  final double totalVolumeKg;
  final int totalDurationSeconds;
  final double? firstPerformanceValue;
  final double? latestPerformanceValue;
  final double improvementValue;
  final double? improvementPercent;
  final DateTime? lastCompletedAt;

  factory ExerciseProgressSummary.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    return ExerciseProgressSummary(
      exerciseKey: data['exerciseKey'] as String? ?? document.id,
      exerciseId: data['exerciseId'] as String?,
      exerciseName: data['exerciseName'] as String? ?? 'Упражнение',
      trackingType: _trackingTypeFromString(data['trackingType']),
      sessionCount: data['sessionCount'] as int? ?? 0,
      approachCount: data['approachCount'] as int? ?? 0,
      personalBestValue:
          (data['personalBestValue'] as num?)?.toDouble() ?? 0,
      bestWeightKg: (data['bestWeightKg'] as num?)?.toDouble(),
      bestReps: data['bestReps'] as int?,
      bestAdditionalWeightKg:
          (data['bestAdditionalWeightKg'] as num?)?.toDouble(),
      bestTotalLoadKg: (data['bestTotalLoadKg'] as num?)?.toDouble(),
      bestDurationSeconds: data['bestDurationSeconds'] as int?,
      totalVolumeKg: (data['totalVolumeKg'] as num?)?.toDouble() ?? 0,
      totalDurationSeconds: data['totalDurationSeconds'] as int? ?? 0,
      firstPerformanceValue:
          (data['firstPerformanceValue'] as num?)?.toDouble(),
      latestPerformanceValue:
          (data['latestPerformanceValue'] as num?)?.toDouble(),
      improvementValue: (data['improvementValue'] as num?)?.toDouble() ?? 0,
      improvementPercent: (data['improvementPercent'] as num?)?.toDouble(),
      lastCompletedAt: _timestampToDateTime(data['lastCompletedAt']),
    );
  }
}

class ExerciseProgressPoint {
  const ExerciseProgressPoint({
    required this.trainingId,
    required this.trainingName,
    required this.performanceValue,
    required this.approachCount,
    required this.orderIndex,
    this.completedAt,
    this.bestWeightKg,
    this.bestReps,
    this.bestAdditionalWeightKg,
    this.bestTotalLoadKg,
    this.bestDurationSeconds,
    this.totalVolumeKg = 0,
    this.totalDurationSeconds = 0,
  });

  final String trainingId;
  final String trainingName;
  final DateTime? completedAt;
  final double performanceValue;
  final double? bestWeightKg;
  final int? bestReps;
  final double? bestAdditionalWeightKg;
  final double? bestTotalLoadKg;
  final int? bestDurationSeconds;
  final double totalVolumeKg;
  final int totalDurationSeconds;
  final int approachCount;
  final int orderIndex;

  factory ExerciseProgressPoint.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    return ExerciseProgressPoint(
      trainingId: data['trainingId'] as String? ?? document.id,
      trainingName: data['trainingName'] as String? ?? 'Тренировка',
      completedAt: _timestampToDateTime(data['completedAt']),
      performanceValue: (data['performanceValue'] as num?)?.toDouble() ?? 0,
      bestWeightKg: (data['bestWeightKg'] as num?)?.toDouble(),
      bestReps: data['bestReps'] as int?,
      bestAdditionalWeightKg:
          (data['bestAdditionalWeightKg'] as num?)?.toDouble(),
      bestTotalLoadKg: (data['bestTotalLoadKg'] as num?)?.toDouble(),
      bestDurationSeconds: data['bestDurationSeconds'] as int?,
      totalVolumeKg: (data['totalVolumeKg'] as num?)?.toDouble() ?? 0,
      totalDurationSeconds: data['totalDurationSeconds'] as int? ?? 0,
      approachCount: data['approachCount'] as int? ?? 0,
      orderIndex: data['orderIndex'] as int? ?? 0,
    );
  }
}

ExerciseTrackingType _trackingTypeFromString(Object? rawValue) {
  final raw = rawValue?.toString();
  return ExerciseTrackingType.values.firstWhere(
    (type) => type.name == raw,
    orElse: () => ExerciseTrackingType.weightReps,
  );
}

DateTime? _timestampToDateTime(Object? rawValue) {
  if (rawValue is Timestamp) {
    return rawValue.toDate();
  }
  return null;
}
