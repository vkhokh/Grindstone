import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dp/colors.dart';
import 'set_menu_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/training_models.dart';
import '../models/timer.dart';

class CurrentWorkoutScreen extends StatefulWidget {
  const CurrentWorkoutScreen({super.key});

  @override
  State<CurrentWorkoutScreen> createState() => _CurrentWorkoutScreenState();
}

class _CurrentWorkoutScreenState extends State<CurrentWorkoutScreen> {
  List<Exercise> exercises = [];
  final TextEditingController exerciseController = TextEditingController();

  // Поле для названия тренировки
  final TextEditingController _trainingNameController = TextEditingController();
  final FocusNode _trainingNameFocusNode = FocusNode();

  // Поле для описания тренировки
  final TextEditingController _trainingDescriptionController = TextEditingController();
  final FocusNode _trainingDescriptionFocusNode = FocusNode();

  bool _isTrainingNameFocused = false;
  bool _isTrainingDescriptionFocused = false;

  @override
  void initState() {
    super.initState();
    _loadTrainingFromPrefs();
    _trainingNameFocusNode.addListener(() {
      setState(() {
        _isTrainingNameFocused = _trainingNameFocusNode.hasFocus;
      });
    });
    _trainingDescriptionFocusNode.addListener(() {
      setState(() {
        _isTrainingDescriptionFocused = _trainingDescriptionFocusNode.hasFocus;
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
        _trainingDescriptionController.text = fullData.basicInfo.description ?? '';
        setState(() {
          exercises = fullData.exercises;
        });
      } catch (e) {
        // Ошибка при загрузке
      }
    }
  }

  // Сохраняем текущее состояние тренировки в SharedPreferences
  Future<void> _saveCurrentTrainingState() async {
    final prefs = await SharedPreferences.getInstance();
    String trainingName = _trainingNameController.text.trim();
    String trainingDescription = _trainingDescriptionController.text.trim();
    if (trainingName.isNotEmpty) {
      final basicInfo = Training(
        name: trainingName,
        description: trainingDescription,
        timer: Timer(hours: 0, minutes: 0, seconds: 0),
        hasTraining: true,
      );
      final fullData = FullTrainingData(
        basicInfo: basicInfo,
        exercises: exercises,
      );
      await prefs.setString('current_training', jsonEncode(fullData.toJson()));
    }
  }

  @override
  void dispose() {
    exerciseController.dispose();
    _trainingNameController.dispose();
    _trainingNameFocusNode.dispose();
    _trainingDescriptionController.dispose();
    _trainingDescriptionFocusNode.dispose();
    super.dispose();
  }

  // Функция для правильного склонения слова "подход"
  String _getApproachWord(int count) {
    if (count % 100 >= 11 && count % 100 <= 19) {
      return 'подходов';
    }
    
    switch (count % 10) {
      case 1:
        return 'подход';
      case 2:
      case 3:
      case 4:
        return 'подхода';
      default:
        return 'подходов';
    }
  }

  // Оформление поля для названия тренировки
  InputDecoration getTrainingNameInputDecoration() {
    return InputDecoration(
      hintText: 'Верх тела, День ног...',
      hintStyle: GoogleFonts.barlow(
        color: hintTextForegroundColor,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      filled: true,
      fillColor: inputInnerColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      alignLabelWithHint: true,
      contentPadding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0),
    );
  }

  // Оформление поля для описания тренировки
  InputDecoration getTrainingDescriptionInputDecoration() {
    return InputDecoration(
      hintText: 'Описание',
      hintStyle: GoogleFonts.barlow(
        color: hintTextForegroundColor,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      filled: true,
      fillColor: inputInnerColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      alignLabelWithHint: true,
      contentPadding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0, right: 16.0),
    );
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
    _saveCurrentTrainingState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Кнопка "назад" в левом верхнем углу
          Positioned(
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: elevatedButtonForegroundColor,
                size: 20,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          // Заголовок "название"
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 18.0, top: 58.0),
                child: Text(
                  'название',
                  style: GoogleFonts.barlow(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // Заголовок "описание"
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 18.0, top: 168.0),
                child: Text(
                  'описание',
                  style: GoogleFonts.barlow(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // Основной контент
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 70),

                // Поле для названия тренировки
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: TextField(
                    onChanged: (value) => _saveCurrentTrainingState(),
                    decoration: getTrainingNameInputDecoration(),
                    controller: _trainingNameController,
                    focusNode: _trainingNameFocusNode,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.barlow(
                      color: elevatedButtonForegroundColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),

                // Поле для описания тренировки
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: TextField(
                    onChanged: (value) => _saveCurrentTrainingState(),
                    decoration: getTrainingDescriptionInputDecoration(),
                    controller: _trainingDescriptionController,
                    focusNode: _trainingDescriptionFocusNode,
                    textAlign: TextAlign.left,
                    // maxLines убран - теперь это однострочное поле
                    style: GoogleFonts.barlow(
                      color: elevatedButtonForegroundColor,
                      fontWeight: FontWeight.normal,
                      fontSize: 18,
                    ),
                  ),
                ),

                // Список упражнений
                Expanded(
                  child: exercises.isEmpty
                      ? const SizedBox()
                      : ListView.builder(
                          itemCount: exercises.length,
                          itemBuilder: (context, index) {
                            final exercise = exercises[index];
                            final hasApproaches = exercise.approaches.isNotEmpty;
                            return GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SetMenuScreen(
                                      exerciseName: exercise.name,
                                      initialApproaches: exercise.approaches,
                                    ),
                                  ),
                                );
                                if (result != null && result is List<Approach>) {
                                  setState(() {
                                    final exerciseIndex = exercises.indexWhere(
                                      (e) => e.name == exercise.name,
                                    );
                                    if (exerciseIndex != -1) {
                                      exercises[exerciseIndex].approaches = result;
                                    }
                                  });
                                  _saveCurrentTrainingState();
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
                                        '${exercise.approaches.length} ${_getApproachWord(exercise.approaches.length)}',
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

          // Нижние кнопки
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48.0, left: 16.0, right: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('current_training');
                      Navigator.pop(context);
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