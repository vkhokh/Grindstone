import 'package:dp/models/exercise_catalog_item.dart';
import 'package:dp/models/timer.dart';

class Approach {
  final int? reps;
  final double? weightKg;
  final int? durationSeconds;

  final bool isBodyweight;
  final double? bodyweightKgSnapshot;
  final double? additionalWeightKg;

  const Approach({
    this.reps,
    this.weightKg,
    this.durationSeconds,
    this.isBodyweight = false,
    this.bodyweightKgSnapshot,
    this.additionalWeightKg,
  });

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weightKg': weightKg,
      'durationSeconds': durationSeconds,
      'isBodyweight': isBodyweight,
      'bodyweightKgSnapshot': bodyweightKgSnapshot,
      'additionalWeightKg': additionalWeightKg,
    };
  }

  static Approach fromJson(Map<String, dynamic> json) {
    return Approach(
      reps: json['reps'] as int?,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      durationSeconds: json['durationSeconds'] as int?,
      isBodyweight: json['isBodyweight'] as bool? ?? false,
      bodyweightKgSnapshot: (json['bodyweightKgSnapshot'] as num?)?.toDouble(),
      additionalWeightKg: (json['additionalWeightKg'] as num?)?.toDouble(),
    );
  }
}

class Exercise {
  final String name;
  final String? exerciseId;
  final ExerciseTrackingType trackingType;
  List<Approach> approaches;

  Exercise({
    required this.name,
    this.exerciseId,
    required this.trackingType,
    this.approaches = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'exerciseId': exerciseId,
      'trackingType': trackingType.name,
      'approaches': approaches.map((a) => a.toJson()).toList(),
    };
  }

  static Exercise fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      exerciseId: json['exerciseId'] as String?,
      trackingType: ExerciseTrackingType.values.firstWhere(
        (e) => e.name == json['trackingType'],
        orElse: () => ExerciseTrackingType.weightReps,
      ),
      approaches: List<Approach>.from(
        (json['approaches'] as List).map((x) => Approach.fromJson(x)),
      ),
    );
  }
}

class Training {
  final String name;
  final String description;
  final bool hasTraining;

  Training({
    required this.name,
    required this.description,
    this.hasTraining = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'hasTraining': hasTraining,
    };
  }

  static Training fromJson(Map<String, dynamic> json) {
    return Training(
      name: json['name'],
      description: json['description'] ?? '',
      hasTraining: json['hasTraining'] ?? true,
    );
  }
}

class FullTrainingData {
  final Training basicInfo;
  List<Exercise> exercises;

  FullTrainingData({required this.basicInfo, this.exercises = const []});

  Map<String, dynamic> toJson() {
    return {
      'basicInfo': basicInfo.toJson(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  static FullTrainingData fromJson(Map<String, dynamic> json) {
    return FullTrainingData(
      basicInfo: Training.fromJson(json['basicInfo']),
      exercises: List<Exercise>.from(
        (json['exercises'] as List).map((x) => Exercise.fromJson(x)),
      ),
    );
  }
}

class TrainingTimer {
  final Timer timer;

  TrainingTimer({required this.timer});

  Map<String, dynamic> toJson() {
    return {'timer': timer.toJson()};
  }

  static TrainingTimer fromJson(Map<String, dynamic> json) {
    return TrainingTimer(timer: Timer.fromJson(json['timer']));
  }
}