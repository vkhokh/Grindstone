import 'package:flutter/material.dart';

final Color backGroundColor = Color(0xFFEBE3D0);
final Color inputInnerColor = Color.fromARGB(240, 214, 204, 204);
final Color elevatedButtonBackgroundColor = Color.fromARGB(240, 240, 169, 28);
final Color elevatedButtonForegroundColor = Color.fromARGB(240, 19, 7, 26);
final Color hintTextForegroundColor = Color.fromARGB(240, 128, 116, 116);
final Color plusButtonColor = Color(0xFFD9D9D9);
final Color textColor = Color(0xFF807474);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Тренировки',
      theme: ThemeData(
        scaffoldBackgroundColor: backGroundColor,
      ),
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
                const Padding(
                  padding: EdgeInsets.only(top: 30, bottom: 20),
                  child: Text(
                    "выберите упражнение",
                    style: TextStyle(
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
                        hintText: 'название упражнения',
                        hintStyle: TextStyle(color: hintTextForegroundColor),
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
                        _saveExercise(exerciseController.text);
                        exerciseController.clear();
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(185, 60),
                      backgroundColor: elevatedButtonBackgroundColor,
                      foregroundColor: elevatedButtonForegroundColor,
                    ),
                    child: const Text(
                      'сохранить',
                      style: TextStyle(
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
      backgroundColor: backGroundColor,
      appBar: AppBar(
        backgroundColor: backGroundColor,
        foregroundColor: elevatedButtonForegroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text( // Убрал const здесь
              "--Название текущей тренировки--",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            
            Padding( // Убрал const здесь
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Text( // Убрал const здесь
                "--Таймер--",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
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
                            color: inputInnerColor,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  exercises[index].name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: elevatedButtonForegroundColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text( // Убрал const здесь
                                '>',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: ElevatedButton(
                    onPressed: _openExerciseDialog,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: const CircleBorder(),
                      backgroundColor: plusButtonColor,
                      foregroundColor: elevatedButtonForegroundColor,
                    ),
                    child: const Text(
                      '+',
                      style: TextStyle(
                        fontSize: 100,
                        fontWeight: FontWeight.w100,
                        height: 0.7,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}