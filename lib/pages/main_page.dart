import 'package:dp/pages/current_training_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dp/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Добавляем импорт для JSON
import '../models/training_models.dart'; // Импортируем модели

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  FullTrainingData? _currentTrainingData;

  @override
  void initState() {
    super.initState();
    _loadCurrentTraining();
  }

  Future<void> _loadCurrentTraining() async {
    final prefs = await SharedPreferences.getInstance();
    final trainingString = prefs.getString('current_training');
    if (trainingString != null) {
      try {
        final jsonMap = jsonDecode(trainingString) as Map<String, dynamic>;
        final fullData = FullTrainingData.fromJson(jsonMap);
        // Проверяем, активна ли тренировка
        if (fullData.basicInfo.hasTraining) {
          setState(() {
            _currentTrainingData = fullData;
          });
        } else {
          // Если hasTraining false, считаем тренировку завершенной
          setState(() {
            _currentTrainingData = null;
          });
        }
      } catch (e) {
        print("Ошибка при загрузке тренировки на главном экране: $e");
        // Сбрасываем, если ошибка
        setState(() {
          _currentTrainingData = null;
        });
      }
    } else {
      // Нет данных в SharedPreferences
      setState(() {
        _currentTrainingData = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasCurrentTraining = _currentTrainingData != null;

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
              height: 312, // Возможно, нужно увеличить высоту, если много упражнений
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: hasCurrentTraining && _currentTrainingData != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentTrainingData!.basicInfo.name,
                            style: GoogleFonts.barlow(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _currentTrainingData!.basicInfo.timer,
                            style: GoogleFonts.barlow(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          // Отображение упражнений
                          Expanded(
                            child: _currentTrainingData!.exercises.isEmpty
                                ? const Text("Нет упражнений", textAlign: TextAlign.center)
                                : ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _currentTrainingData!.exercises.length,
                                    itemBuilder: (context, idx) {
                                      final ex = _currentTrainingData!.exercises[idx];
                                      final hasApproaches = ex.approaches.isNotEmpty;
                                      // Формируем строку с информацией об упражнении
                                      String exInfo = ex.name;
                                      if (hasApproaches) {
                                        exInfo += " (${ex.approaches.length} подходов)";
                                        // Опционально: показать первый подход
                                        // if (ex.approaches.isNotEmpty) {
                                        //   exInfo += "\n${ex.approaches[0].reps} x ${ex.approaches[0].weight} кг";
                                        // }
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                                        child: Text(
                                          exInfo,
                                          style: GoogleFonts.barlow(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CurrentWorkoutScreen(),
                                ),
                              ).then((result) {
                                // Обновляем данные после возврата из CurrentWorkoutScreen
                                // CurrentWorkoutScreen сам удаляет запись при завершении
                                _loadCurrentTraining();
                              });
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
                          // Кнопка "Завершить тренировку больше не нужна на главном экране,
                          // так как она теперь в CurrentWorkoutScreen
                        ],
                      )
                    : const SizedBox.shrink(), // Используем SizedBox.shrink() если нет тренировки
              ),
            ),
            const SizedBox(height: 40),

            // Нижние кнопки: "Начать тренировку" и "Архив тренировок"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // При нажатии "Начать тренировку" можно очистить старую
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('current_training');
                      setState(() {
                        _currentTrainingData = null;
                      });

                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CurrentWorkoutScreen()),
                      );
                      // После создания новой тренировки, CurrentWorkoutScreen сохранит её
                      // и MainPage автоматически загрузит новую тренировку при следующем открытии
                      _loadCurrentTraining(); // Попробуем обновить
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
                    child: const Text('Начать\nтренировку', textAlign: TextAlign.center),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
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
                    child: const Text('Архив\nтренировок', textAlign: TextAlign.center),
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