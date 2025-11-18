import 'package:flutter/material.dart';
import '../models/workout.dart';

class WorkoutProvider with ChangeNotifier {
  List<Workout> _workouts = [];
  List<Workout> get workouts => [..._workouts]; 


  Workout? _currentWorkout;
  Workout? get currentWorkout => _currentWorkout;


  void setCurrentWorkout(Workout? workout) {
    _currentWorkout = workout;
    notifyListeners();
  }

  void createWorkout(String name) {
    final newWorkout = Workout(name: name);
    _workouts.add(newWorkout);
    _currentWorkout = newWorkout; 
    notifyListeners();
  }

  void addExerciseToCurrent(String exerciseName) {
    if (_currentWorkout != null) {
      final newExercise = Exercise(name: exerciseName);

      final updatedExercises = [..._currentWorkout!.exercises, newExercise];


      final updatedWorkout = Workout(
        name: _currentWorkout!.name,
        exercises: updatedExercises,
      );


      final index = _workouts.indexOf(_currentWorkout!);
      if (index != -1) {

        _workouts[index] = updatedWorkout;
      }

      _currentWorkout = updatedWorkout;
      notifyListeners();
    }
  }

  void addSetToExercise(int exerciseIndex, double weight, int reps) {
    if (_currentWorkout != null && exerciseIndex < _currentWorkout!.exercises.length) {
      final newSet = Set(weight: weight, reps: reps);

      final oldExercise = _currentWorkout!.exercises[exerciseIndex];

      final updatedSets = [...oldExercise.sets, newSet];

      final updatedExercise = Exercise(
        name: oldExercise.name,
        sets: updatedSets,
      );

      final updatedExercises = List<Exercise>.from(_currentWorkout!.exercises)..[exerciseIndex] = updatedExercise;

      final updatedWorkout = Workout(
        name: _currentWorkout!.name,
        exercises: updatedExercises,
      );

      final index = _workouts.indexOf(_currentWorkout!);
      if (index != -1) {
        _workouts[index] = updatedWorkout;
      }

      _currentWorkout = updatedWorkout;
      notifyListeners();
    }
  }

  double get totalProgress {
    return _workouts.fold<double>(0, (sum, workout) => sum + workout.totalProgress);
  }
}