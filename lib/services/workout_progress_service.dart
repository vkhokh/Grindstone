import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/archived_training.dart';
import '../models/exercise_catalog_item.dart';
import '../models/training_models.dart';
import '../models/workout_progress.dart';

class WorkoutProgressService {
  WorkoutProgressService._();

  static final WorkoutProgressService instance = WorkoutProgressService._();

  static const String _overviewDocumentId = 'summary';
  static const Duration _readTimeout = Duration(seconds: 15);
  static const Duration _streamInitialTimeout = Duration(seconds: 12);
  static const Duration _writeTimeout = Duration(seconds: 20);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<WorkoutProgressOverview> watchOverview() {
    return _auth
        .authStateChanges()
        .asyncExpand((user) {
          if (user == null) {
            return Stream.value(const WorkoutProgressOverview.empty());
          }

          return _overviewDocument(user.uid).snapshots().map((snapshot) {
            if (!snapshot.exists) {
              return const WorkoutProgressOverview.empty();
            }
            return WorkoutProgressOverview.fromFirestore(snapshot);
          });
        })
        .timeout(
          _streamInitialTimeout,
          onTimeout: (sink) {
            sink.add(const WorkoutProgressOverview.empty());
          },
        );
  }

  Stream<List<ExerciseProgressSummary>> watchExerciseSummaries() {
    return _auth
        .authStateChanges()
        .asyncExpand((user) {
          if (user == null) {
            return Stream.value(const <ExerciseProgressSummary>[]);
          }

          return _exerciseProgressCollection(user.uid)
              .orderBy('lastCompletedAt', descending: true)
              .snapshots()
              .map(
                (snapshot) => snapshot.docs
                    .map(ExerciseProgressSummary.fromFirestore)
                    .toList(),
              );
        })
        .timeout(
          _streamInitialTimeout,
          onTimeout: (sink) {
            sink.add(const <ExerciseProgressSummary>[]);
          },
        );
  }

  Stream<List<ExerciseProgressPoint>> watchExercisePoints(String exerciseKey) {
    return _auth
        .authStateChanges()
        .asyncExpand((user) {
          if (user == null) {
            return Stream.value(const <ExerciseProgressPoint>[]);
          }

          return _pointsCollection(user.uid, exerciseKey)
              .orderBy('completedAt')
              .snapshots()
              .map(
                (snapshot) => snapshot.docs
                    .map(ExerciseProgressPoint.fromFirestore)
                    .toList(),
              );
        })
        .timeout(
          _streamInitialTimeout,
          onTimeout: (sink) {
            sink.add(const <ExerciseProgressPoint>[]);
          },
        );
  }

  Future<void> ensureProgressData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final overviewSnapshot = await _overviewDocument(
      user.uid,
    ).get().timeout(_readTimeout);
    if (overviewSnapshot.exists) return;

    final archiveSnapshot = await _archiveCollection(
      user.uid,
    ).limit(1).get().timeout(_readTimeout);
    if (archiveSnapshot.docs.isEmpty) return;

    await recomputeProgress();
  }

  Future<void> recomputeProgress() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No signed in user',
      );
    }

    final archiveSnapshot = await _archiveCollection(
      user.uid,
    ).orderBy('completedAt').get().timeout(_readTimeout);
    final archivedTrainings = archiveSnapshot.docs
        .map(ArchivedTraining.fromFirestore)
        .toList();

    final overviewAccumulator = _OverviewAccumulator();
    final accumulators = <String, _ExerciseProgressAccumulator>{};

    for (
      var trainingOrder = 0;
      trainingOrder < archivedTrainings.length;
      trainingOrder++
    ) {
      final archivedTraining = archivedTrainings[trainingOrder];
      overviewAccumulator.totalTrainings += 1;
      overviewAccumulator.totalApproaches += archivedTraining.approachCount;
      overviewAccumulator.updateLastCompletedAt(archivedTraining.completedAt);

      final groupedExercises = <String, _TrainingExerciseBucket>{};
      for (final exercise in archivedTraining.exercises) {
        final exerciseKey = _buildExerciseKey(exercise);
        final bucket = groupedExercises.putIfAbsent(
          exerciseKey,
          () => _TrainingExerciseBucket(
            exerciseKey: exerciseKey,
            exerciseId: exercise.exerciseId,
            exerciseName: exercise.name.trim().isEmpty
                ? 'Упражнение'
                : exercise.name.trim(),
            trackingType: exercise.trackingType,
          ),
        );
        bucket.approaches.addAll(exercise.approaches);
      }

      for (final bucket in groupedExercises.values) {
        final metrics = _buildMetrics(bucket.trackingType, bucket.approaches);
        if (!metrics.hasTrackedData) {
          continue;
        }

        overviewAccumulator.totalExerciseSessions += 1;
        overviewAccumulator.totalVolumeKg += metrics.totalVolumeKg;
        overviewAccumulator.totalDurationSeconds +=
            metrics.totalDurationSeconds;

        final accumulator = accumulators.putIfAbsent(
          bucket.exerciseKey,
          () => _ExerciseProgressAccumulator(
            exerciseKey: bucket.exerciseKey,
            exerciseId: bucket.exerciseId,
            exerciseName: bucket.exerciseName,
            trackingType: bucket.trackingType,
          ),
        );

        accumulator.addPoint(
          _ProgressPointWriteModel(
            trainingId: archivedTraining.id,
            trainingName: archivedTraining.name,
            completedAt: archivedTraining.completedAt ?? DateTime.now().toUtc(),
            performanceValue: metrics.performanceValue,
            bestWeightKg: metrics.bestWeightKg,
            bestReps: metrics.bestReps,
            bestAdditionalWeightKg: metrics.bestAdditionalWeightKg,
            bestTotalLoadKg: metrics.bestTotalLoadKg,
            bestDurationSeconds: metrics.bestDurationSeconds,
            totalVolumeKg: metrics.totalVolumeKg,
            totalDurationSeconds: metrics.totalDurationSeconds,
            approachCount: metrics.approachCount,
            orderIndex: trainingOrder,
          ),
        );
      }
    }

    overviewAccumulator.uniqueExercises = accumulators.length;

    await _replaceProgressData(
      uid: user.uid,
      overview: overviewAccumulator.toFirestore(),
      accumulators: accumulators,
    );
  }

  CollectionReference<Map<String, dynamic>> _archiveCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('workoutArchive');
  }

  DocumentReference<Map<String, dynamic>> _overviewDocument(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('progressOverview')
        .doc(_overviewDocumentId);
  }

  CollectionReference<Map<String, dynamic>> _exerciseProgressCollection(
    String uid,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('exerciseProgress');
  }

  CollectionReference<Map<String, dynamic>> _pointsCollection(
    String uid,
    String exerciseKey,
  ) {
    return _exerciseProgressCollection(
      uid,
    ).doc(exerciseKey).collection('points');
  }

  Future<void> _replaceProgressData({
    required String uid,
    required Map<String, dynamic> overview,
    required Map<String, _ExerciseProgressAccumulator> accumulators,
  }) async {
    WriteBatch batch = _firestore.batch();
    var operationCount = 0;

    Future<void> flushBatch() async {
      if (operationCount == 0) return;
      await batch.commit().timeout(_writeTimeout);
      batch = _firestore.batch();
      operationCount = 0;
    }

    Future<void> queueDelete(
      DocumentReference<Map<String, dynamic>> ref,
    ) async {
      batch.delete(ref);
      operationCount += 1;
      if (operationCount >= 400) {
        await flushBatch();
      }
    }

    Future<void> queueSet(
      DocumentReference<Map<String, dynamic>> ref,
      Map<String, dynamic> data,
    ) async {
      batch.set(ref, data);
      operationCount += 1;
      if (operationCount >= 400) {
        await flushBatch();
      }
    }

    final existingSummaries = await _exerciseProgressCollection(uid).get();
    for (final summaryDocument in existingSummaries.docs) {
      final existingPoints = await summaryDocument.reference
          .collection('points')
          .get()
          .timeout(_readTimeout);
      for (final pointDocument in existingPoints.docs) {
        await queueDelete(pointDocument.reference);
      }
      await queueDelete(summaryDocument.reference);
    }

    await queueSet(_overviewDocument(uid), {
      ...overview,
      'generatedAt': FieldValue.serverTimestamp(),
      'schemaVersion': 1,
    });

    for (final accumulator in accumulators.values) {
      await queueSet(
        _exerciseProgressCollection(uid).doc(accumulator.exerciseKey),
        accumulator.buildSummaryData(),
      );

      for (final point in accumulator.points) {
        await queueSet(
          _pointsCollection(uid, accumulator.exerciseKey).doc(point.trainingId),
          point.toFirestore(),
        );
      }
    }

    await flushBatch();
  }

  String _buildExerciseKey(Exercise exercise) {
    final exerciseId = exercise.exerciseId?.trim();
    if (exerciseId != null && exerciseId.isNotEmpty) {
      return 'id_${_normalizeKeyPart(exerciseId)}';
    }

    return 'name_${_normalizeKeyPart(exercise.name)}';
  }

  String _normalizeKeyPart(String value) {
    final normalized = value.trim().toLowerCase();
    final safe = normalized.replaceAll(RegExp(r'[^a-z0-9а-яё]+'), '_');
    final compact = safe.replaceAll(RegExp(r'_+'), '_');
    return compact.replaceAll(RegExp(r'^_|_$'), '');
  }

  _ExerciseMetrics _buildMetrics(
    ExerciseTrackingType trackingType,
    List<Approach> approaches,
  ) {
    switch (trackingType) {
      case ExerciseTrackingType.weightReps:
        return _buildWeightMetrics(approaches);
      case ExerciseTrackingType.bodyweightReps:
        return _buildBodyweightMetrics(approaches);
      case ExerciseTrackingType.duration:
        return _buildDurationMetrics(approaches);
    }
  }

  _ExerciseMetrics _buildWeightMetrics(List<Approach> approaches) {
    double bestWeightKg = 0;
    int bestReps = 0;
    double totalVolumeKg = 0;
    double performanceValue = 0;
    var trackedApproaches = 0;

    for (final approach in approaches) {
      final reps = approach.reps;
      final weightKg = approach.weightKg;
      if (reps == null || reps <= 0 || weightKg == null || weightKg <= 0) {
        continue;
      }

      trackedApproaches += 1;
      totalVolumeKg += reps * weightKg;
      if (weightKg > bestWeightKg) {
        bestWeightKg = weightKg;
      }
      if (reps > bestReps) {
        bestReps = reps;
      }

      final estimatedOneRepMax = weightKg * (1 + reps / 30);
      if (estimatedOneRepMax > performanceValue) {
        performanceValue = estimatedOneRepMax;
      }
    }

    return _ExerciseMetrics(
      approachCount: trackedApproaches,
      performanceValue: performanceValue,
      bestWeightKg: trackedApproaches == 0 ? null : bestWeightKg,
      bestReps: trackedApproaches == 0 ? null : bestReps,
      totalVolumeKg: totalVolumeKg,
    );
  }

  _ExerciseMetrics _buildBodyweightMetrics(List<Approach> approaches) {
    double bestAdditionalWeightKg = 0;
    double bestTotalLoadKg = 0;
    int bestReps = 0;
    double totalVolumeKg = 0;
    double performanceValue = 0;
    var trackedApproaches = 0;

    for (final approach in approaches) {
      final reps = approach.reps;
      if (reps == null || reps <= 0) {
        continue;
      }

      final additionalWeightKg = approach.additionalWeightKg ?? 0;
      final totalLoadKg =
          (approach.bodyweightKgSnapshot ?? 0) + additionalWeightKg;

      trackedApproaches += 1;
      totalVolumeKg += reps * totalLoadKg;
      if (additionalWeightKg > bestAdditionalWeightKg) {
        bestAdditionalWeightKg = additionalWeightKg;
      }
      if (totalLoadKg > bestTotalLoadKg) {
        bestTotalLoadKg = totalLoadKg;
      }
      if (reps > bestReps) {
        bestReps = reps;
      }

      final estimatedOneRepMax = totalLoadKg * (1 + reps / 30);
      if (estimatedOneRepMax > performanceValue) {
        performanceValue = estimatedOneRepMax;
      }
    }

    return _ExerciseMetrics(
      approachCount: trackedApproaches,
      performanceValue: performanceValue,
      bestReps: trackedApproaches == 0 ? null : bestReps,
      bestAdditionalWeightKg: trackedApproaches == 0
          ? null
          : bestAdditionalWeightKg,
      bestTotalLoadKg: trackedApproaches == 0 ? null : bestTotalLoadKg,
      totalVolumeKg: totalVolumeKg,
    );
  }

  _ExerciseMetrics _buildDurationMetrics(List<Approach> approaches) {
    var bestDurationSeconds = 0;
    var totalDurationSeconds = 0;
    var trackedApproaches = 0;

    for (final approach in approaches) {
      final durationSeconds = approach.durationSeconds;
      if (durationSeconds == null || durationSeconds <= 0) {
        continue;
      }

      trackedApproaches += 1;
      totalDurationSeconds += durationSeconds;
      if (durationSeconds > bestDurationSeconds) {
        bestDurationSeconds = durationSeconds;
      }
    }

    return _ExerciseMetrics(
      approachCount: trackedApproaches,
      performanceValue: bestDurationSeconds.toDouble(),
      bestDurationSeconds: trackedApproaches == 0 ? null : bestDurationSeconds,
      totalDurationSeconds: totalDurationSeconds,
    );
  }
}

class _OverviewAccumulator {
  int totalTrainings = 0;
  int totalExerciseSessions = 0;
  int totalApproaches = 0;
  int uniqueExercises = 0;
  double totalVolumeKg = 0;
  int totalDurationSeconds = 0;
  DateTime? lastCompletedAt;

  void updateLastCompletedAt(DateTime? value) {
    if (value == null) return;
    if (lastCompletedAt == null || value.isAfter(lastCompletedAt!)) {
      lastCompletedAt = value;
    }
  }

  Map<String, dynamic> toFirestore() {
    final data = <String, dynamic>{
      'totalTrainings': totalTrainings,
      'totalExerciseSessions': totalExerciseSessions,
      'totalApproaches': totalApproaches,
      'uniqueExercises': uniqueExercises,
      'totalVolumeKg': totalVolumeKg,
      'totalDurationSeconds': totalDurationSeconds,
    };

    if (lastCompletedAt != null) {
      data['lastCompletedAt'] = lastCompletedAt;
    }

    return data;
  }
}

class _TrainingExerciseBucket {
  _TrainingExerciseBucket({
    required this.exerciseKey,
    required this.exerciseId,
    required this.exerciseName,
    required this.trackingType,
  });

  final String exerciseKey;
  final String? exerciseId;
  final String exerciseName;
  final ExerciseTrackingType trackingType;
  final List<Approach> approaches = <Approach>[];
}

class _ExerciseMetrics {
  const _ExerciseMetrics({
    required this.approachCount,
    required this.performanceValue,
    this.bestWeightKg,
    this.bestReps,
    this.bestAdditionalWeightKg,
    this.bestTotalLoadKg,
    this.bestDurationSeconds,
    this.totalVolumeKg = 0,
    this.totalDurationSeconds = 0,
  });

  final int approachCount;
  final double performanceValue;
  final double? bestWeightKg;
  final int? bestReps;
  final double? bestAdditionalWeightKg;
  final double? bestTotalLoadKg;
  final int? bestDurationSeconds;
  final double totalVolumeKg;
  final int totalDurationSeconds;

  bool get hasTrackedData => approachCount > 0 && performanceValue > 0;
}

class _ExerciseProgressAccumulator {
  _ExerciseProgressAccumulator({
    required this.exerciseKey,
    required this.exerciseId,
    required this.exerciseName,
    required this.trackingType,
  });

  final String exerciseKey;
  final String? exerciseId;
  final String exerciseName;
  final ExerciseTrackingType trackingType;
  final List<_ProgressPointWriteModel> points = <_ProgressPointWriteModel>[];

  void addPoint(_ProgressPointWriteModel point) {
    points.add(point);
  }

  Map<String, dynamic> buildSummaryData() {
    points.sort((a, b) => a.completedAt.compareTo(b.completedAt));

    var approachCount = 0;
    double personalBestValue = 0;
    double totalVolumeKg = 0;
    var totalDurationSeconds = 0;
    double? bestWeightKg;
    int? bestReps;
    double? bestAdditionalWeightKg;
    double? bestTotalLoadKg;
    int? bestDurationSeconds;

    for (final point in points) {
      approachCount += point.approachCount;
      totalVolumeKg += point.totalVolumeKg;
      totalDurationSeconds += point.totalDurationSeconds;
      if (point.performanceValue > personalBestValue) {
        personalBestValue = point.performanceValue;
      }
      bestWeightKg = _maxDouble(bestWeightKg, point.bestWeightKg);
      bestReps = _maxInt(bestReps, point.bestReps);
      bestAdditionalWeightKg = _maxDouble(
        bestAdditionalWeightKg,
        point.bestAdditionalWeightKg,
      );
      bestTotalLoadKg = _maxDouble(bestTotalLoadKg, point.bestTotalLoadKg);
      bestDurationSeconds = _maxInt(
        bestDurationSeconds,
        point.bestDurationSeconds,
      );
    }

    final firstPerformanceValue = points.isEmpty
        ? null
        : points.first.performanceValue;
    final latestPerformanceValue = points.isEmpty
        ? null
        : points.last.performanceValue;
    final improvementValue =
        firstPerformanceValue == null || latestPerformanceValue == null
        ? 0
        : latestPerformanceValue - firstPerformanceValue;
    final improvementPercent =
        firstPerformanceValue == null || firstPerformanceValue <= 0
        ? null
        : (improvementValue / firstPerformanceValue) * 100;

    final data = <String, dynamic>{
      'exerciseKey': exerciseKey,
      'exerciseName': exerciseName,
      'trackingType': trackingType.name,
      'sessionCount': points.length,
      'approachCount': approachCount,
      'personalBestValue': personalBestValue,
      'totalVolumeKg': totalVolumeKg,
      'totalDurationSeconds': totalDurationSeconds,
      'improvementValue': improvementValue,
      'lastCompletedAt': points.isEmpty ? null : points.last.completedAt,
    };

    if (exerciseId != null && exerciseId!.isNotEmpty) {
      data['exerciseId'] = exerciseId;
    }
    if (bestWeightKg != null) {
      data['bestWeightKg'] = bestWeightKg;
    }
    if (bestReps != null) {
      data['bestReps'] = bestReps;
    }
    if (bestAdditionalWeightKg != null) {
      data['bestAdditionalWeightKg'] = bestAdditionalWeightKg;
    }
    if (bestTotalLoadKg != null) {
      data['bestTotalLoadKg'] = bestTotalLoadKg;
    }
    if (bestDurationSeconds != null) {
      data['bestDurationSeconds'] = bestDurationSeconds;
    }
    if (firstPerformanceValue != null) {
      data['firstPerformanceValue'] = firstPerformanceValue;
    }
    if (latestPerformanceValue != null) {
      data['latestPerformanceValue'] = latestPerformanceValue;
    }
    if (improvementPercent != null) {
      data['improvementPercent'] = improvementPercent;
    }

    return data;
  }

  double? _maxDouble(double? current, double? next) {
    if (next == null) return current;
    if (current == null || next > current) {
      return next;
    }
    return current;
  }

  int? _maxInt(int? current, int? next) {
    if (next == null) return current;
    if (current == null || next > current) {
      return next;
    }
    return current;
  }
}

class _ProgressPointWriteModel {
  const _ProgressPointWriteModel({
    required this.trainingId,
    required this.trainingName,
    required this.completedAt,
    required this.performanceValue,
    required this.approachCount,
    required this.orderIndex,
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
  final DateTime completedAt;
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

  Map<String, dynamic> toFirestore() {
    final data = <String, dynamic>{
      'trainingId': trainingId,
      'trainingName': trainingName,
      'completedAt': completedAt,
      'performanceValue': performanceValue,
      'totalVolumeKg': totalVolumeKg,
      'totalDurationSeconds': totalDurationSeconds,
      'approachCount': approachCount,
      'orderIndex': orderIndex,
    };

    if (bestWeightKg != null) {
      data['bestWeightKg'] = bestWeightKg;
    }
    if (bestReps != null) {
      data['bestReps'] = bestReps;
    }
    if (bestAdditionalWeightKg != null) {
      data['bestAdditionalWeightKg'] = bestAdditionalWeightKg;
    }
    if (bestTotalLoadKg != null) {
      data['bestTotalLoadKg'] = bestTotalLoadKg;
    }
    if (bestDurationSeconds != null) {
      data['bestDurationSeconds'] = bestDurationSeconds;
    }

    return data;
  }
}
