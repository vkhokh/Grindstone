import 'package:cloud_firestore/cloud_firestore.dart';

import 'training_models.dart';

class ArchivedTraining {
  const ArchivedTraining({
    required this.id,
    required this.training,
    required this.exerciseCount,
    required this.approachCount,
    this.completedAt,
  });

  final String id;
  final FullTrainingData training;
  final int exerciseCount;
  final int approachCount;
  final DateTime? completedAt;

  String get name => training.basicInfo.name;
  String get description => training.basicInfo.description;
  List<Exercise> get exercises => training.exercises;

  factory ArchivedTraining.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final rawTraining = data['training'];
    final trainingJson = rawTraining is Map<String, dynamic>
        ? rawTraining
        : Map<String, dynamic>.from(rawTraining as Map? ?? <String, dynamic>{});

    final training = FullTrainingData.fromJson(trainingJson);

    return ArchivedTraining(
      id: document.id,
      training: training,
      exerciseCount:
          data['exerciseCount'] as int? ?? training.exercises.length,
      approachCount:
          data['approachCount'] as int? ?? countApproaches(training.exercises),
      completedAt: _timestampToDateTime(data['completedAt']),
    );
  }

  static int countApproaches(List<Exercise> exercises) {
    return exercises.fold<int>(
      0,
      (sum, exercise) => sum + exercise.approaches.length,
    );
  }

  static DateTime? _timestampToDateTime(Object? rawValue) {
    if (rawValue is Timestamp) {
      return rawValue.toDate();
    }
    return null;
  }
}
