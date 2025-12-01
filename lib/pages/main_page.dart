// pages/main_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dp/colors.dart';
import '/models/workout.dart'; // Импортируем модель Workout
import 'current_workout_page.dart'; // Для навигации
import '../providers/workout_provider.dart'; // Для получения данных

// Удаляем старую модель Training, если она больше не нужна в этом файле
// class Training { ... }

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    // Получаем провайдер
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final currentWorkout = workoutProvider.currentWorkout;

    // Определяем, есть ли активная тренировка
    bool hasCurrentTraining = currentWorkout != null;

    // Пример таймера (пока просто строка, можно реализовать логику таймера позже)
    String timer = "00:00"; // Заглушка, нужно реализовать логику таймера

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 159,
                  height: 238,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                ),
                Container(
                  width: 146,
                  height: 146,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.only(right: 36),
                  child: Image.asset('assets/images/icon_user.png', fit: BoxFit.contain),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Блок текущей тренировки
            SizedBox(
              width: 360,
              height: 312,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: hasCurrentTraining
                    ? Column(
                        children: [
                          Text(
                            currentWorkout.name, // Берем имя из WorkoutProvider
                            style: GoogleFonts.barlow(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            timer, // Показываем таймер (пока заглушка)
                            style: GoogleFonts.barlow(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          // Кнопка "перейти в текущую тренировку"
                          ElevatedButton(
                            onPressed: () {
                              // Навигация на страницу текущей тренировки
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CurrentWorkoutPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: elevatedButtonBackgroundColor,
                              foregroundColor: elevatedButtonForegroundColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                              textStyle: GoogleFonts.barlow(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text('перейти в текущую тренировку'),
                          ),
                          const SizedBox(height: 15),
                          // Кнопка "завершить трен"
                          ElevatedButton(
                            onPressed: () {
                              // Логика завершения тренировки
                              workoutProvider.setCurrentWorkout(null); // Сбрасываем текущую тренировку
                              // Можно добавить логику сохранения или очистки
                              // Например, переместить тренировку из current в архив
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: elevatedButtonBackgroundColor,
                              foregroundColor: elevatedButtonForegroundColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                              textStyle: GoogleFonts.barlow(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text('завершить тренировку'),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(), // Если нет тренировки, показываем пустое пространство
              ),
            ),
            const SizedBox(height: 40),
            // Нижние кнопки: "Начать тренировку" и "Архив тренировок"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Навигация на страницу создания новой тренировки
                      Navigator.pushNamed(context, '/create_workout');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: elevatedButtonBackgroundColor,
                      foregroundColor: elevatedButtonForegroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      textStyle: GoogleFonts.barlow(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text(
                      'Начать\nтренировку',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Навигация на страницу архива тренировок (пока не реализована)
                      // Navigator.pushNamed(context, '/archive');
                      // Пока просто покажем SnackBar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Архив тренировок: не реализовано')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: elevatedButtonBackgroundColor,
                      foregroundColor: elevatedButtonForegroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      textStyle: GoogleFonts.barlow(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text(
                      'Архив\nтренировок',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}