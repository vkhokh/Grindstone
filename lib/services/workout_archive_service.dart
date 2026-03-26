import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/archived_training.dart';
import '../models/training_models.dart';

class WorkoutArchiveService {
  WorkoutArchiveService._();

  static final WorkoutArchiveService instance = WorkoutArchiveService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ArchivedTraining>> watchArchive() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) {
        return Stream.value(const <ArchivedTraining>[]);
      }

      return _archiveCollection(user.uid)
          .orderBy('completedAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map(ArchivedTraining.fromFirestore)
                .toList(),
          );
    });
  }

  Future<void> archiveTraining(FullTrainingData training) async {
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

    await _archiveCollection(user.uid).add({
      'training': normalizedTraining.toJson(),
      'exerciseCount': exerciseCount,
      'approachCount': approachCount,
      'completedAt': FieldValue.serverTimestamp(),
    });
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
            approaches: exercise.approaches
                .map(
                  (approach) => Approach(
                    reps: approach.reps.trim(),
                    weight: approach.weight.trim(),
                  ),
                )
                .toList(),
          ),
        )
        .toList();

    return FullTrainingData(basicInfo: basicInfo, exercises: exercises);
  }
}
