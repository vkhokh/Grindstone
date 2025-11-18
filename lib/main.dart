import 'package:dp/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/start_page.dart';
import 'pages/create_workout_page.dart';
import 'pages/current_workout_page.dart';
import 'pages/add_exercise_page.dart';
import 'pages/add_set_page.dart';
import 'providers/workout_provider.dart';

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WorkoutProvider(),
      child: MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => StartPage(),
          '/create_workout': (context) => CreateWorkoutPage(),
          '/current_workout': (context) => CurrentWorkoutPage(),
          '/add_exercise': (context) => AddExercisePage(),
          '/add_set': (context) => AddSetPage(exerciseIndex: 0), 
        },
        theme: mainTheme,
      ),
    );
  }
}