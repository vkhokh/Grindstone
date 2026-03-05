import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dp/colors.dart';
import '../models/training_models.dart';

const Color plusButtonColor = Color(0xFFD9D9D9);

class SetMenuScreen extends StatefulWidget {
  final String exerciseName;
  final List<Approach> initialApproaches;

  const SetMenuScreen({super.key, required this.exerciseName, this.initialApproaches = const []});

  @override
  State<SetMenuScreen> createState() => _SetMenuScreenState();
}

class _SetMenuScreenState extends State<SetMenuScreen> {
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();

  List<Approach> _approaches = [];
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _approaches = List.from(widget.initialApproaches);
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _returnResult() {
    Navigator.pop(context, _approaches);
  }

  void _openAddApproachDialog() {
    _editingIndex = null;
    _repsController.clear();
    _weightController.clear();
    _showApproachDialog();
  }

  void _openEditApproachDialog(int index) {
    _editingIndex = index;
    final approach = _approaches[index];
    _repsController.text = approach.reps;
    _weightController.text = approach.weight;
    _showApproachDialog();
  }

  void _showApproachDialog() {
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
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    _editingIndex == null ? 'добавить подход' : 'редактировать подход',
                    style: GoogleFonts.barlow(
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
                      controller: _repsController,
                      decoration: InputDecoration(
                        hintText: 'количество повторений',
                        hintStyle: GoogleFonts.barlow(
                          color: hintTextForegroundColor,
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
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: SizedBox(
                    width: 288,
                    height: 56,
                    child: TextField(
                      controller: _weightController,
                      decoration: InputDecoration(
                        hintText: 'вес (кг)',
                        hintStyle: GoogleFonts.barlow(
                          color: hintTextForegroundColor,
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
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_repsController.text.isNotEmpty && _weightController.text.isNotEmpty) {
                        if (_editingIndex == null) {
                          _addApproach();
                        } else {
                          _updateApproach(_editingIndex!);
                        }
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(185, 60),
                      backgroundColor: elevatedButtonBackgroundColor,
                      foregroundColor: elevatedButtonForegroundColor,
                    ),
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

  void _addApproach() {
    setState(() {
      _approaches.add(Approach(
        reps: _repsController.text,
        weight: _weightController.text,
      ));
    });
  }

  void _updateApproach(int index) {
    setState(() {
      _approaches[index] = Approach(
        reps: _repsController.text,
        weight: _weightController.text,
      );
    });
  }

  void _deleteApproach(int index) {
    setState(() {
      _approaches.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      body: Column(
        children: [
          // Кастомная шапка
          Padding(
            padding: const EdgeInsets.only(top: 50.0, left: 8.0, right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: elevatedButtonForegroundColor),
                  onPressed: _returnResult,
                ),
                Text(
                  widget.exerciseName,
                  style: GoogleFonts.barlow(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: elevatedButtonForegroundColor,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // Основной контент (список подходов)
          Expanded(
            child: Padding(
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
                                key: ValueKey(approach),
                                direction: DismissDirection.endToStart,
                                onDismissed: (direction) {
                                  _deleteApproach(index);
                                },
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                child: GestureDetector(
                                  onTap: () => _openEditApproachDialog(index),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: inputInnerColor,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Подход №${index + 1}: ${approach.reps} x ${approach.weight} кг",
                                          style: GoogleFonts.barlow(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: elevatedButtonForegroundColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),

          // Кнопка "добавить подход" (оранжевый прямоугольник)
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Center(
              child: ElevatedButton(
                onPressed: _openAddApproachDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: elevatedButtonBackgroundColor,
                  foregroundColor: elevatedButtonForegroundColor,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Скруглённые углы
                  ),
                ),
                child: Text(
                  'добавить подход',
                  style: GoogleFonts.barlow(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}