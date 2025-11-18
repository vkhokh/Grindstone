class Workout {
  String name;
  List<Exercise> exercises;

  Workout({required this.name, this.exercises = const []});


  void addExercise(Exercise exercise) {
    exercises.add(exercise);
  }

  double get totalProgress {
    return exercises.fold<double>(0, (sum, exercise) {
      return sum + exercise.totalWeightLifted;
    });
  }
}

class Exercise {
  String name;
  List<Set> sets;

  Exercise({required this.name, this.sets = const []});

  void addSet(Set set) {
    sets.add(set);
  }

  double get totalWeightLifted {
    return sets.fold<double>(0, (sum, set) {
      return sum + (set.weight * set.reps);
    });
  }
}

class Set {
  double weight; 
  int reps;      
  Set({required this.weight, required this.reps});
}