import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/exercise_catalog_item.dart';

class CustomExerciseService {
  CustomExerciseService._();

  static final CustomExerciseService instance = CustomExerciseService._();

  static const String _storageKey = 'custom_exercises';

  Future<List<ExerciseCatalogItem>> loadExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw) as List;
      return decoded
          .map((item) => ExerciseCatalogItem.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveExercises(List<ExerciseCatalogItem> exercises) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      exercises.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> addExercise(ExerciseCatalogItem exercise) async {
    final current = await loadExercises();

    final alreadyExists = current.any(
      (e) => e.name.trim().toLowerCase() == exercise.name.trim().toLowerCase(),
    );

    if (alreadyExists) return;

    current.add(exercise);
    await saveExercises(current);
  }
}