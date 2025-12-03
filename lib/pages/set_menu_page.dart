import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dp/colors.dart';
import '../models/training_models.dart'; // Импортируем модели

class SetMenuScreen extends StatefulWidget {
  final String exerciseName;
  final List<Approach> initialApproaches; // Добавляем список подходов

  const SetMenuScreen({super.key, required this.exerciseName, this.initialApproaches = const []});

  @override
  _SetMenuScreenState createState() => _SetMenuScreenState();
}

class _SetMenuScreenState extends State<SetMenuScreen> {
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();

  List<Approach> _approaches = [];

  @override
  void initState() {
    super.initState();
    // Загружаем начальные подходы при инициализации
    _approaches = List.from(widget.initialApproaches); // Создаём копию
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _addApproach() {
    if (_repsController.text.isNotEmpty && _weightController.text.isNotEmpty) {
      setState(() {
        _approaches.add(Approach(
          reps: _repsController.text,
          weight: _weightController.text,
        ));
      });
      _repsController.clear();
      _weightController.clear();
    }
  }

  void _deleteApproach(int index) {
    setState(() {
      _approaches.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.exerciseName,
          style: GoogleFonts.barlow(
            fontWeight: FontWeight.bold,
            color: elevatedButtonForegroundColor,
          ),
        ),
        backgroundColor: backGroundColor,
        foregroundColor: elevatedButtonForegroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _approaches.isEmpty
                  ? const Center(child: Text("Нет добавленных подходов"))
                  : ListView.builder(
                      itemCount: _approaches.length,
                      itemBuilder: (context, index) {
                        final approach = _approaches[index];
                        return Dismissible(
                          key: Key('$index'),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) => _deleteApproach(index),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            margin: EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: inputInnerColor,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Подход №${index + 1}: ${approach.reps} × ${approach.weight} кг",
                                  style: GoogleFonts.barlow(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: elevatedButtonForegroundColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  TextField(
                    controller: _repsController,
                    decoration: InputDecoration(
                      labelText: "Повторения",
                      filled: false,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      labelText: "Вес (кг)",
                      filled: false,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: _addApproach,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: elevatedButtonBackgroundColor,
                      foregroundColor: elevatedButtonForegroundColor,
                    ),
                    child: Text(
                      "Добавить подход",
                      style: GoogleFonts.barlow(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _approaches.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pop(context, _approaches); // Возвращаем обновлённый список подходов
              },
              backgroundColor: elevatedButtonBackgroundColor,
              foregroundColor: elevatedButtonForegroundColor,
              child: Icon(Icons.check),
            )
          : null,
    );
  }
}