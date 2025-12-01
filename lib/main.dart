// lib/main.dart

import 'package:dp/theme/theme.dart'; // Импорт вашей темы
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/start_page.dart'; // Предполагается, что StartPage ведет на MainPage
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
      create: (context) => WorkoutProvider(), // Создание провайдера
      child: MaterialApp(
        title: 'Grindstone', // Название приложения (необязательно)
        // Установка начального маршрута на StartPage (где заставка)
        initialRoute: '/',
        routes: {
          // Маршрут '/' теперь ведет на StartPage (заставка)
          '/': (context) => const StartPage(),
          // Маршрут для создания тренировки
          '/create_workout': (context) => const CreateWorkoutPage(),
          // Маршрут для текущей тренировки
          '/current_workout': (context) => const CurrentWorkoutPage(),
          // Маршрут для добавления упражнения (может быть не нужен напрямую, если через навигацию)
          '/add_exercise': (context) => const AddExercisePage(),
          // Маршрут для добавления сета (передаем индекс упражнения, поэтому используем builder)
          // '/add_set': (context) => AddSetPage(exerciseIndex: 0), // Не используем в routes из-за параметра
          // MainPage теперь не в routes, так как на нее переходит StartPage
        },
        // Обновленный onGenerateRoute для /add_set, так как он принимает параметры
        onGenerateRoute: (settings) {
          if (settings.name == '/add_set') {
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null && args.containsKey('exerciseIndex')) {
              final int exerciseIndex = args['exerciseIndex'] as int;
              return MaterialPageRoute(
                builder: (context) => AddSetPage(exerciseIndex: exerciseIndex),
              );
            }
          }
          // Для остальных маршрутов, не попавших в routes, можно вернуть ошибку
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(child: Text('Страница не найдена')),
            ),
          );
        },
        theme: mainTheme, // Применение вашей темы
      ),
    );
  }
}