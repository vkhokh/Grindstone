import 'package:dp/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Импортируем ваши цвета и тему
import 'package:dp/colors.dart'; // Убедитесь, что путь правильный

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Тренировки',
      theme: mainTheme, // Применяем вашу тему
      home: const CurrentWorkoutScreen(),
    );
  }
}

class Exercise {
  final String name;
  
  Exercise({required this.name});
}

class CurrentWorkoutScreen extends StatefulWidget {
  const CurrentWorkoutScreen({super.key});

  @override
  State<CurrentWorkoutScreen> createState() => _CurrentWorkoutScreenState();
}

class _CurrentWorkoutScreenState extends State<CurrentWorkoutScreen> {
  List<Exercise> exercises = [];
  final TextEditingController exerciseController = TextEditingController();

  // --- НАЧАЛО: Код из TrainingScreen (q.txt) для названия тренировки ---
  final TextEditingController _trainingNameController = TextEditingController();
  final FocusNode _trainingNameFocusNode = FocusNode(); // Новый FocusNode

  // Состояние для отслеживания, редактируется ли поле
  bool _isTrainingNameFocused = false;

  @override
  void initState() {
    super.initState();
    // Слушаем изменения фокуса
    _trainingNameFocusNode.addListener(() {
      setState(() {
        _isTrainingNameFocused = _trainingNameFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    exerciseController.dispose(); // Добавим очистку и этого контроллера
    _trainingNameController.dispose();
    _trainingNameFocusNode.dispose();
    super.dispose();
  }

  // Определяем стиль InputDecoration в зависимости от состояния
  InputDecoration getTrainingNameInputDecoration() {
    // Если поле в фокусе ИЛИ поле не в фокусе И пустое (для подсказки), показываем рамку и заливку
    if (_isTrainingNameFocused || _trainingNameController.text.trim().isEmpty) {
      return InputDecoration(
        hintText: '--название тренировки--',
        hintStyle: GoogleFonts.barlow( // Используем ваш шрифт
          color: hintTextForegroundColor, // Используем цвет подсказки из ваших assets
          fontWeight: FontWeight.bold,
          fontSize: 18, // Уменьшенный размер шрифта для подсказки
        ),
        filled: true, // Заливка активна при фокусе или когда пусто
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
      // Если поле НЕ в фокусе И содержит текст, убираем заливку и рамку
      return InputDecoration(
        filled: false, // Нет заливки
        border: InputBorder.none, // Нет рамки
        enabledBorder: InputBorder.none, // Нет рамки
        focusedBorder: InputBorder.none, // Нет рамки
      );
    }
  }
  // --- КОНЕЦ: Код из TrainingScreen (q.txt) для названия тренировки ---

  void _openExerciseDialog() { // Убираем параметр initialName
    exerciseController.text = ""; // Очистим поле

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          backgroundColor: backGroundColor, // Используем ваш цвет фона
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
                    style: GoogleFonts.barlow( // Используем ваш шрифт
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: elevatedButtonForegroundColor, // Используем ваш цвет текста
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
                        hintStyle: GoogleFonts.barlow( // Используем ваш шрифт и цвет
                          color: hintTextForegroundColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        filled: false, // Оставляем как было
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2.0),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2.0),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2.0),
                        ),
                      ),
                      controller: exerciseController,
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: ElevatedButton( // Используем стиль из темы
                    onPressed: () {
                      if (exerciseController.text.isNotEmpty) {
                        String exerciseName = exerciseController.text;
                        _saveExercise(exerciseName); // Добавить новое упражнение
                        exerciseController.clear();
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      'сохранить',
                      style: GoogleFonts.barlow( // Используем ваш шрифт
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
      exercises.add(Exercise(name: name));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Убрали AppBar, будем рисовать его вручную
      body: Stack( // Используем Stack, как в TrainingScreen
        children: [
          // Основной контент
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 70), // Верхний отступ как в TrainingScreen
                // --- НАЧАЛО: Поле для названия тренировки (как в TrainingScreen (q.txt)) ---
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextField(
                    decoration: getTrainingNameInputDecoration(), // Используем динамически созданный стиль из TrainingScreen
                    controller: _trainingNameController, // Привязываем контроллер из TrainingScreen
                    focusNode: _trainingNameFocusNode, // Привязываем FocusNode из TrainingScreen
                    textAlign: TextAlign.center,
                    style: GoogleFonts.barlow( // Стиль текста, который вводит пользователь (из TrainingScreen)
                      color: elevatedButtonForegroundColor, // Используем цвет из ваших assets
                      fontWeight: FontWeight.bold,
                      fontSize: 24, // Размер шрифта для введённого текста (из TrainingScreen)
                    ),
                  ),
                ),
                // --- КОНЕЦ: Поле для названия тренировки ---
                
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Container(
                    width: double.infinity, // Занимает всю ширину
                    child: Text(
                      "--Таймер--",
                      textAlign: TextAlign.center, // Центрируем текст
                      style: GoogleFonts.barlow( // Используем ваш шрифт
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: hintTextForegroundColor, // Используем ваш цвет подсказки
                      ),
                    ),
                  ),
                ),
                
                Expanded(
                  child: exercises.isEmpty
                      ? const SizedBox()
                      : ListView.builder(
                          itemCount: exercises.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 354,
                              height: 41,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: inputInnerColor, // Используем ваш серый цвет
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      exercises[index].name,
                                      style: GoogleFonts.barlow( // Используем ваш шрифт
                                        fontSize: 16,
                                        color: elevatedButtonForegroundColor, // Используем ваш цвет текста
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Убираем IconButton и возвращаем просто текст '>'
                                  Text(
                                    '>',
                                    style: GoogleFonts.barlow( // Используем ваш шрифт
                                      fontSize: 20,
                                      color: elevatedButtonForegroundColor, // Используем ваш цвет текста
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          // Кнопки внизу (как в TrainingScreen)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Кнопка "Сохранить"
                  ElevatedButton(
                    onPressed: () {
                      String trainingName = _trainingNameController.text.trim();
                      if (trainingName.isNotEmpty) {
                        // Здесь можно добавить логику сохранения всей тренировки
                        // debugPrint("Тренировка '$trainingName' сохранена с ${exercises.length} упражнениями.");
                      } else {
                        // Можно показать Snackbar или AlertDialog, если название не введено
                        // debugPrint("Пожалуйста, введите название тренировки.");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(179, 65), // Размер кнопки как в TrainingScreen
                    ),
                    child: Text(
                      'завершить тренировку',
                      style: GoogleFonts.barlow(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Кнопка "Добавить упражнение" (как в TrainingScreen, вызывает _openExerciseDialog)
                  ElevatedButton(
                    onPressed: _openExerciseDialog, // Вызывает диалог добавления
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(179, 65), // Размер кнопки как в TrainingScreen
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