import 'package:dp/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dp/colors.dart';
import 'set_menu_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Класс для передачи данных о тренировке
class Training {
  final String name;
  final String timer;
  final bool hasTraining;

  Training({
    required this.name,
    required this.timer,
    this.hasTraining = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'timer': timer,
      'hasTraining': hasTraining,
    };
  }

  static Training fromJson(Map<String, dynamic> json) {
    return Training(
      name: json['name'],
      timer: json['timer'],
      hasTraining: json['hasTraining'] ?? true,
    );
  }
}

class Exercise {
  final String name;
  List<Approach> approaches;

  Exercise({required this.name, this.approaches = const []});
}

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
    _trainingNameFocusNode.addListener(() {
      setState(() {
        _isTrainingNameFocused = _trainingNameFocusNode.hasFocus;
      });
    });
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 70),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextField(
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
                    child: Text(
                      "--Таймер--",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.barlow(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: hintTextForegroundColor,
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
                            final exercise = exercises[index];
                            final hasApproaches = exercise.approaches.isNotEmpty;
                            return GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SetMenuScreen(exerciseName: exercise.name),
                                  ),
                                );
                                if (result != null && result is List<Approach>) {
                                  setState(() {
                                    exercise.approaches = result;
                                  });
                                }
                              },
                              child: Container(
                                width: 354,
                                height: 41,
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                      String trainingName = _trainingNameController.text.trim();
                      if (trainingName.isNotEmpty) {
                        final prefs = await SharedPreferences.getInstance();
                        final training = Training(
                          name: trainingName,
                          timer: "--Таймер--",
                          hasTraining: true,
                        );
                        await prefs.setString('current_training', training.toJson().toString());
                        Navigator.pop(context, training);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Пожалуйста, введите название тренировки.")),
                        );
                      }
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