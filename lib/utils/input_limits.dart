import 'package:flutter/material.dart';

class AppInputLimits {
  static const int email = 254;
  static const int password = 128;
  static const int userName = 40;
  static const int height = 3;
  static const int profileWeight = 6;
  static const int trainingName = 60;
  static const int trainingDescription = 160;
  static const int exerciseName = 60;
  static const int exerciseSearchQuery = 60;
  static const int reps = 4;
  static const int weight = 6;
  static const int durationMinutes = 4;
  static const int durationSeconds = 2;
}

Widget? hiddenMaxLengthCounter(
  BuildContext context, {
  required int currentLength,
  required bool isFocused,
  required int? maxLength,
}) {
  return null;
}
