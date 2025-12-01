import 'package:dp/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Импортируем ваши цвета и тему
import 'package:dp/colors.dart';
import 'package:google_fonts/google_fonts.dart'; // Убедитесь, что путь правильный

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: mainTheme, // Применяем вашу тему ко всему приложению
      home: TrainingScreen(),
    );
  }
}

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  TrainingScreenState createState() => TrainingScreenState();
}

class TrainingScreenState extends State<TrainingScreen> {
  final TextEditingController _exerciseController = TextEditingController();
  final TextEditingController _trainingNameController = TextEditingController();
  final FocusNode _trainingNameFocusNode = FocusNode(); // Новый FocusNode

  List<String> exercises = [];

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
    _exerciseController.dispose();
    _trainingNameController.dispose();
    _trainingNameFocusNode.dispose();
    super.dispose();
  }

  void _openExerciseDialog([String? initialName]) {
    _exerciseController.text = initialName ?? "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          backgroundColor: Color(0xFFEBE3D0), // Background color (как было изначально)
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 20),
                  child: Text(
                    "Выберите упражнение",
                    style: TextStyle( // Оставляем как было
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
                        hintText: 'Название упражнения',
                        hintStyle: TextStyle(color: Colors.grey), // Как было
                        filled: false, // Как было (без заливки)
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
                      controller: _exerciseController,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      String exerciseName = _exerciseController.text;
                      if (exerciseName.isNotEmpty) {
                        setState(() {
                          if (initialName != null) {
                            int index = exercises.indexOf(initialName);
                            exercises[index] = exerciseName; // Обновляем существующее упражнение
                          } else {
                            exercises.add(exerciseName); // Добавляем новое упражнение
                          }
                        });
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(185, 60),
                      backgroundColor:elevatedButtonBackgroundColor, // Как было (можно заменить на elevatedButtonBackgroundColor, если хотите)
                      foregroundColor:elevatedButtonForegroundColor, // Как было
                      shadowColor: Colors.black.withValues(alpha: 2),
                      elevation: 5,
                    ),
                    child: Text(
                      'Сохранить',
                      style: TextStyle( // Как было
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

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      body: Stack(
        children: [
          // Основной контент
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 70), // Верхний отступ
                // Поле для названия тренировки
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextField(
                    decoration: getTrainingNameInputDecoration(), // Используем динамически созданный стиль
                    controller: _trainingNameController,
                    focusNode: _trainingNameFocusNode, // Привязываем FocusNode
                    textAlign: TextAlign.center,
                    style: GoogleFonts.barlow( // Стиль текста, который вводит пользователь
                      color: elevatedButtonForegroundColor, // Используем цвет из ваших assets вместо Colors.black
                      fontWeight: FontWeight.bold,
                      fontSize: 24, // Размер шрифта для введённого текста
                    ),
                  ),
                ),
                // Список упражнений
                Expanded(
                  child: ListView.builder(
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: inputInnerColor, // Используем серый цвет из ваших assets
                        ),
                        child: ListTile(
                          title: Text(
                            exercises[index],
                            style: GoogleFonts.barlow( // Используем ваш шрифт
                              fontSize: 16,
                              color: elevatedButtonForegroundColor, // Цвет текста упражнения тоже из assets
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.edit, color: elevatedButtonForegroundColor), // Цвет иконки из assets
                            onPressed: () {
                              _openExerciseDialog(exercises[index]);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Кнопки внизу
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
                        if (kDebugMode) {
                          debugPrint("Тренировка '$trainingName' сохранена с ${exercises.length} упражнениями.");
                        }
                      } else {
                        // Можно показать Snackbar или AlertDialog, если название не введено
                        if (kDebugMode) {
                          debugPrint("Пожалуйста, введите название тренировки.");
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(179, 65), // Размер кнопки
                    ),
                    child: Text(
                      'сохранить',
                      style: GoogleFonts.barlow(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Кнопка "Добавить упражнение"
                  ElevatedButton(
                    onPressed: _openExerciseDialog,
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(179, 65), // Размер кнопки
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