import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dp/colors.dart';
import 'set_menu_page.dart'; // Предполагается, что путь к файлу правильный
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Добавляем импорт для JSON
import '../models/training_models.dart'; // Импортируем модели
import '../models/timer.dart';

class CurrentWorkoutScreen extends StatefulWidget {
  const CurrentWorkoutScreen({super.key});

  @override
  State<CurrentWorkoutScreen> createState() => _CurrentWorkoutScreenState();
}

class _CurrentWorkoutScreenState extends State<CurrentWorkoutScreen> {
  List<Exercise> exercises = [];
  final TextEditingController exerciseController = TextEditingController();

  final TextEditingController _trainingNameController = TextEditingController();
  final FocusNode _trainingNameFocusNode = FocusNode();

  bool _isTrainingNameFocused = false;

  @override
  void initState() {
    super.initState();
    _loadTrainingFromPrefs(); // Загружаем данные при инициализации
    _trainingNameFocusNode.addListener(() {
      setState(() {
        _isTrainingNameFocused = _trainingNameFocusNode.hasFocus;
      });
    });
  }

  // Загружаем полную информацию о тренировке из SharedPreferences
  Future<void> _loadTrainingFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final trainingString = prefs.getString('current_training');
    if (trainingString != null) {
      try {
        final jsonMap = jsonDecode(trainingString) as Map<String, dynamic>;
        final fullData = FullTrainingData.fromJson(jsonMap);
        _trainingNameController.text = fullData.basicInfo.name;
        setState(() {
          exercises = fullData.exercises; // Устанавливаем упражнения
        });
      } catch (e) {
        // print("Ошибка при загрузке тренировки: $e");
        // Оставляем как есть или сбрасываем
      }
    }
  }

  // Сохраняем текущее состояние тренировки в SharedPreferences
  Future<void> _saveCurrentTrainingState() async {
    final prefs = await SharedPreferences.getInstance();
    String trainingName = _trainingNameController.text.trim();
    if (trainingName.isNotEmpty) {
      final basicInfo = Training(
        name: trainingName,
        timer: Timer(hours: 0, minutes: 0, seconds: 0),
        hasTraining: true, // Указывает, что тренировка активна
      );
      final fullData = FullTrainingData(
        basicInfo: basicInfo,
        exercises: exercises, // Сохраняем текущие упражнения
      );
      await prefs.setString('current_training', jsonEncode(fullData.toJson()));
    }
  }

  @override
  void dispose() {
    exerciseController.dispose();
    _trainingNameController.dispose();
    _trainingNameFocusNode.dispose();
    super.dispose();
  }

  InputDecoration getTrainingNameInputDecoration() {
    if (_isTrainingNameFocused || _trainingNameController.text.trim().isEmpty) {
      return InputDecoration(
        hintText: '--название тренировки--',
        hintStyle: GoogleFonts.barlow(
          color: hintTextForegroundColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        filled: true,
        fillColor: inputInnerColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(width: 2, color: inputOutlineBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(width: 4, color: inputOutlineBorderColor),
        ),
      );
    } else {
      return InputDecoration(
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      );
    }
  }

  void _openExerciseDialog() {
    exerciseController.text = "";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          backgroundColor: backGroundColor,
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 20),
                  child: Text(
                    "выберите упражнение",
                    style: GoogleFonts.barlow(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: elevatedButtonForegroundColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: SizedBox(
                    width: 288,
                    height: 56,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'название упражнения',
                        hintStyle: GoogleFonts.barlow(
                          color: hintTextForegroundColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        filled: false,
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                      ),
                      controller: exerciseController,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      if (exerciseController.text.isNotEmpty) {
                        String exerciseName = exerciseController.text;
                        _saveExercise(exerciseName);
                        exerciseController.clear();
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      'сохранить',
                      style: GoogleFonts.barlow(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveExercise(String name) {
    setState(() {
      exercises.add(Exercise(name: name, approaches: []));
    });
    _saveCurrentTrainingState(); // Сохраняем после добавления упражнения
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Кнопка "назад" в левом верхнем углу
          Positioned(
            // top: 40,
            // left: 16,
            child: IconButton(
              icon: Icon(
                Icons
                    .arrow_back, // Или используйте Icons.close, если предпочитаете крестик
                color: elevatedButtonForegroundColor, // Используем ваш цвет
                size: 20,
              ),
              onPressed: () {
                Navigator.pop(context); // Просто возвращаемся назад
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 70),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextField(
                    onChanged: (value) =>
                        _saveCurrentTrainingState(), // Сохраняем при изменении имени
                    decoration: getTrainingNameInputDecoration(),
                    controller: _trainingNameController,
                    focusNode: _trainingNameFocusNode,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.barlow(
                      color: elevatedButtonForegroundColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Container(
                    width: double.infinity,
                    // child: Text(
                    //   "00:00:00",
                    //   textAlign: TextAlign.center,
                    //   style: GoogleFonts.barlow(
                    //     fontSize: 18,
                    //     fontWeight: FontWeight.bold,
                    //     color: hintTextForegroundColor,
                    //   ),
                    // ),
                  ),
                ),
                Expanded(
                  child: exercises.isEmpty
                      ? const SizedBox()
                      : ListView.builder(
                          itemCount: exercises.length,
                          itemBuilder: (context, index) {
                            final exercise = exercises[index];
                            final hasApproaches =
                                exercise.approaches.isNotEmpty;
                            return GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    // Передаём имя и текущие подходы
                                    builder: (context) => SetMenuScreen(
                                      exerciseName: exercise.name,
                                      initialApproaches: exercise.approaches,
                                    ),
                                  ),
                                );
                                if (result != null &&
                                    result is List<Approach>) {
                                  setState(() {
                                    // Находим упражнение по индексу и заменяем его подходы
                                    // (предполагаем, что индекс не изменился между навигацией)
                                    // Более надёжно - найти по имени
                                    final exerciseIndex = exercises.indexWhere(
                                      (e) => e.name == exercise.name,
                                    );
                                    if (exerciseIndex != -1) {
                                      exercises[exerciseIndex].approaches =
                                          result;
                                    }
                                    // Альтернатива: просто переназначить список, если индекс надёжен
                                    // exercise.approaches = result;
                                  });
                                  _saveCurrentTrainingState(); // Сохраняем при изменении подходов
                                }
                              },
                              child: Container(
                                width: 354,
                                height: 41,
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: inputInnerColor,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        exercise.name,
                                        style: GoogleFonts.barlow(
                                          fontSize: 16,
                                          color: elevatedButtonForegroundColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (hasApproaches)
                                      Text(
                                        '${exercise.approaches.length} подходов',
                                        style: GoogleFonts.barlow(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    Text(
                                      ' >',
                                      style: GoogleFonts.barlow(
                                        fontSize: 20,
                                        color: elevatedButtonForegroundColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Завершаем тренировку: удаляем из SharedPreferences
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('current_training');
                      Navigator.pop(context); // Возвращаемся без результата
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(179, 65),
                    ),
                    child: Text(
                      'завершить тренировку',
                      style: GoogleFonts.barlow(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _openExerciseDialog,
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(179, 65),
                    ),
                    child: Text(
                      'добавить\nупражнение',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.barlow(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
