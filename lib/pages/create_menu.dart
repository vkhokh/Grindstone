import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  final TextEditingController _controller = TextEditingController();
  List<String> exercises = [];

  void _openExerciseDialog([String? initialName]) {
    _controller.text = initialName ?? "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          backgroundColor: Color(0xFFEBE3D0), // Background color
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 30, bottom: 20),
                  child: Text(
                    "Выберите упражнение",
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
                        hintText: 'Название упражнения',
                        hintStyle: TextStyle(color: Colors.grey),
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
                      controller: _controller,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      String exerciseName = _controller.text;
                      if (exerciseName.isNotEmpty) {
                        setState(() {
                          if (initialName != null) {
                            int index = exercises.indexOf(initialName);
                            exercises[index] = exerciseName;  // Update existing exercise
                          } else {
                            exercises.add(exerciseName);  // Add new exercise
                          }
                        });
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(185, 60),
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      shadowColor: Colors.black.withOpacity(0.3),
                      elevation: 5,),
                    child: const Text(
                      'Сохранить',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 70), // Top margin roughly 2-3 cm
                Text(
                  "--Название тренировки--",
                  style: TextStyle(
                    fontSize: 24, // Increased font size
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 20),
                // Display the exercises
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
                          color: Color(0xFFE0E0E0), // Exercise background
                        ),
                        child: ListTile(
                          title: Text(
                            exercises[index],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.edit, color: Colors.black),
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
          // Buttons at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // "Save" button
                  ElevatedButton(
                    onPressed: () {
                      String trainingName = "Тренировка сохранена: ${_controller.text}";
                      if (kDebugMode) {
                        debugPrint(trainingName);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      shadowColor: Colors.black.withOpacity(0.3),
                      elevation: 5,
                      minimumSize: Size(100, 45), // Same size for both buttons
                    ),
                    child: Text(
                      'Сохранить',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),),
                  // "Add Exercise" button
                  ElevatedButton(
                    onPressed: _openExerciseDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      shadowColor: Colors.black.withOpacity(0.3),
                      elevation: 5,
                      minimumSize: Size(100, 45), // Same size for both buttons
                    ),
                    child: Text(
                      'Добавить упражнение',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
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
