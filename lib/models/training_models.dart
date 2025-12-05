import 'package:dp/models/timer.dart';

class Approach {
  final String reps;
  final String weight;

  Approach({required this.reps, required this.weight});

  Map<String, dynamic> toJson() {
    return {'reps': reps, 'weight': weight};
  }

  static Approach fromJson(Map<String, dynamic> json) {
    return Approach(reps: json['reps'], weight: json['weight']);
  }
}

class Exercise {
  final String name;
  List<Approach> approaches;

  Exercise({required this.name, this.approaches = const []});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'approaches': approaches.map((a) => a.toJson()).toList(),
    };
  }

  static Exercise fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      approaches: List<Approach>.from(
        (json['approaches'] as List).map((x) => Approach.fromJson(x)),
      ),
    );
  }
}

class Training {
  final String name;
  final Timer timer;
  final bool hasTraining;

  Training({required this.name, required this.timer, this.hasTraining = true});

  Map<String, dynamic> toJson() {
    return {'name': name, 'timer': timer.toJson(), 'hasTraining': hasTraining};
  }

  static Training fromJson(Map<String, dynamic> json) {
    return Training(
      name: json['name'],
      timer: Timer.fromJson(json['timer']),
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
