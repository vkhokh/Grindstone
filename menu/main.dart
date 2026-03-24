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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавить тренировку'),
        backgroundColor: Colors.orange,
      ),
      body: Stack(
        children: [
          // Основной контент
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Поле для ввода названия тренировки
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Введите название тренировки',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                SizedBox(height: 20),
                // Добавь остальные элементы, если нужно
              ],
            ),
          ),
          // Кнопки внизу экрана
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
                      // Сохранить тренировку
                      String trainingName = _controller.text;
                      // Логика сохранения
                      if (kDebugMode) {
                        debugPrint('Тренировка сохранена: $trainingName');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, // Цвет кнопки
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    ),
                    child: Text(
                      'Сохранить',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // Кнопка "Добавить упражнение"
                  ElevatedButton(
                    onPressed: () {
                      // Логика добавления упражнения
                      if (kDebugMode) {
                        debugPrint('Добавить упражнение');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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