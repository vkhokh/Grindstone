import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/archived_training.dart';
import '../models/training_models.dart';
import 'workout_progress_service.dart';

class WorkoutArchiveService {
  WorkoutArchiveService._();

  static final WorkoutArchiveService instance = WorkoutArchiveService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const Duration _writeTimeout = Duration(seconds: 20);
  static const Duration _streamInitialTimeout = Duration(seconds: 12);
  static const Duration _progressRecomputeTimeout = Duration(seconds: 30);

  String createArchiveId() {
    return _firestore.collection('_archiveIds').doc().id;
  }

  Stream<List<ArchivedTraining>> watchArchive() {
    return _auth
        .authStateChanges()
        .asyncExpand((user) {
          if (user == null) {
            return Stream.value(const <ArchivedTraining>[]);
          }

          return _archiveCollection(user.uid)
              .orderBy('completedAt', descending: true)
              .snapshots()
              .map(
                (snapshot) =>
                    snapshot.docs.map(ArchivedTraining.fromFirestore).toList(),
              );
        })
        .timeout(
          _streamInitialTimeout,
          onTimeout: (sink) {
            sink.add(const <ArchivedTraining>[]);
          },
        );
  }

  Future<void> archiveTraining(
    FullTrainingData training, {
    String? archiveId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No signed in user',
      );
    }

    final normalizedTraining = _normalizeTraining(training);
    final exerciseCount = normalizedTraining.exercises.length;
    final approachCount = ArchivedTraining.countApproaches(
      normalizedTraining.exercises,
    );

    final archiveData = {
      'training': normalizedTraining.toJson(),
      'exerciseCount': exerciseCount,
      'approachCount': approachCount,
      'completedAt': FieldValue.serverTimestamp(),
    };

    final normalizedArchiveId = archiveId?.trim();
    if (normalizedArchiveId == null || normalizedArchiveId.isEmpty) {
      await _archiveCollection(
        user.uid,
      ).add(archiveData).timeout(_writeTimeout);
    } else {
      await _archiveCollection(
        user.uid,
      ).doc(normalizedArchiveId).set(archiveData).timeout(_writeTimeout);
    }

    _scheduleProgressRecompute();
  }

  Future<void> deleteTraining(String trainingId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No signed in user',
      );
    }

    await _archiveCollection(
      user.uid,
    ).doc(trainingId).delete().timeout(_writeTimeout);

    _scheduleProgressRecompute();
  }

  void _scheduleProgressRecompute() {
    unawaited(_recomputeProgressInBackground());
  }

  Future<void> _recomputeProgressInBackground() async {
    try {
      await WorkoutProgressService.instance.recomputeProgress().timeout(
        _progressRecomputeTimeout,
      );
    } catch (_) {
      // Progress can be restored later from the workout archive if sync fails.
    }
  }

  CollectionReference<Map<String, dynamic>> _archiveCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('workoutArchive');
  }

  FullTrainingData _normalizeTraining(FullTrainingData training) {
    final basicInfo = Training(
      name: training.basicInfo.name.trim(),
      description: training.basicInfo.description.trim(),
      hasTraining: true,
    );

    final exercises = training.exercises
        .map(
          (exercise) => Exercise(
            name: exercise.name.trim(),
            exerciseId: exercise.exerciseId,
            trackingType: exercise.trackingType,
            approaches: exercise.approaches
                .map(
                  (approach) => Approach(
                    reps: approach.reps,
                    weightKg: approach.weightKg,
                    durationSeconds: approach.durationSeconds,
                    isBodyweight: approach.isBodyweight,
                    bodyweightKgSnapshot: approach.bodyweightKgSnapshot,
                    additionalWeightKg: approach.additionalWeightKg,
                  ),
                )
                .toList(),
          ),
        )
        .toList();

    return FullTrainingData(basicInfo: basicInfo, exercises: exercises);
  }
}
