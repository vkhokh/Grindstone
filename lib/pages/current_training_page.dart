import 'dart:convert';

import 'package:dp/colors.dart';
import 'package:dp/pages/set_menu_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/training_models.dart';

class CurrentWorkoutScreen extends StatefulWidget {
  const CurrentWorkoutScreen({super.key});

  @override
  State<CurrentWorkoutScreen> createState() => _CurrentWorkoutScreenState();
}

class _CurrentWorkoutScreenState extends State<CurrentWorkoutScreen> {
  List<Exercise> exercises = [];

  final TextEditingController exerciseController = TextEditingController();
  final TextEditingController _trainingNameController = TextEditingController();
  final TextEditingController _trainingDescriptionController =
      TextEditingController();

  final FocusNode _trainingNameFocusNode = FocusNode();
  final FocusNode _trainingDescriptionFocusNode = FocusNode();

  static const Color _screenBackground = Color(0xFFF7F3EA);
  static const Color _cardColor = Color(0xFFFFFBF5);
  static const Color _inputColor = Colors.white;
  static const Color _borderSoft = Color(0xFFE8E2D6);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _softTileColor = Color(0xFFFCF7EF);
  static const Color _dangerColor = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _loadTrainingFromPrefs();

    _trainingNameFocusNode.addListener(() {
      setState(() {});
    });

    _trainingDescriptionFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    exerciseController.dispose();
    _trainingNameController.dispose();
    _trainingDescriptionController.dispose();
    _trainingNameFocusNode.dispose();
    _trainingDescriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadTrainingFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final trainingString = prefs.getString('current_training');

    if (trainingString != null) {
      try {
        final jsonMap = jsonDecode(trainingString) as Map<String, dynamic>;
        final fullData = FullTrainingData.fromJson(jsonMap);

        _trainingNameController.text = fullData.basicInfo.name;
        _trainingDescriptionController.text =
            fullData.basicInfo.description ?? '';

        setState(() {
          exercises = fullData.exercises;
        });
      } catch (_) {}
    }
  }

  Future<void> _saveCurrentTrainingState() async {
    final prefs = await SharedPreferences.getInstance();

    final trainingName = _trainingNameController.text.trim();
    final trainingDescription = _trainingDescriptionController.text.trim();

    if (trainingName.isNotEmpty) {
      final basicInfo = Training(
        name: trainingName,
        description: trainingDescription,
        hasTraining: true,
      );

      final fullData = FullTrainingData(
        basicInfo: basicInfo,
        exercises: exercises,
      );

      await prefs.setString('current_training', jsonEncode(fullData.toJson()));
    }
  }

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

  void _saveExercise(String name) {
    setState(() {
      exercises.add(Exercise(name: name, approaches: []));
    });
    _saveCurrentTrainingState();
  }

  void _deleteExercise(int index) {
    setState(() {
      exercises.removeAt(index);
    });
    _saveCurrentTrainingState();
  }

  Future<void> _finishTraining() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_training');

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _openExercise(Exercise exercise) async {
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
        final exerciseIndex = exercises.indexWhere((e) => e.name == exercise.name);
        if (exerciseIndex != -1) {
          exercises[exerciseIndex].approaches = result;
        }
      });
      _saveCurrentTrainingState();
    }
  }

  void _openExerciseBottomSheet() {
    exerciseController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 16,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Добавить упражнение',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Введите название упражнения для этой тренировки',
                  style: TextStyle(
                    fontSize: 15,
                    color: _textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                _buildModalInputField(
                  controller: exerciseController,
                  hintText: 'Например: Жим лёжа',
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final exerciseName = exerciseController.text.trim();
                      if (exerciseName.isEmpty) return;

                      _saveExercise(exerciseName);
                      Navigator.of(bottomSheetContext).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: elevatedButtonBackgroundColor,
                      foregroundColor: elevatedButtonForegroundColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Сохранить упражнение',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
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
      backgroundColor: backGroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  children: [
                    _buildCustomHeader(),
                    const SizedBox(height: 18),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildTrainingInfoCard(),
                            const SizedBox(height: 16),
                            _buildExercisesCard(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final topSpacing = (screenHeight * 0.01).clamp(6.0, 14.0);
    final headerHeight = (screenHeight * 0.065).clamp(48.0, 64.0);
    final backButtonSize = (screenWidth * 0.11).clamp(40.0, 48.0);
    final iconSize = (screenWidth * 0.065).clamp(22.0, 30.0);
    final titleFontSize = (screenWidth * 0.06).clamp(22.0, 28.0);

    return Padding(
      padding: EdgeInsets.only(top: topSpacing),
      child: SizedBox(
        height: headerHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: _handleBack,
                child: SizedBox(
                  width: backButtonSize,
                  height: backButtonSize,
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: _textPrimary,
                    size: iconSize,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: backButtonSize + 8),
              child: Text(
                'Тренировка',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: titleFontSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _borderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildFieldBlock(
            label: 'НАЗВАНИЕ',
            child: _buildInputField(
              controller: _trainingNameController,
              hintText: 'Верх тела, День ног...',
              onChanged: (_) => _saveCurrentTrainingState(),
              focusNode: _trainingNameFocusNode,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildFieldBlock(
            label: 'ОПИСАНИЕ',
            child: _buildInputField(
              controller: _trainingDescriptionController,
              hintText: 'Описание тренировки',
              onChanged: (_) => _saveCurrentTrainingState(),
              focusNode: _trainingDescriptionFocusNode,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _borderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Упражнения',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${exercises.length}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (exercises.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
              decoration: BoxDecoration(
                color: _softTileColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.fitness_center_rounded,
                    size: 36,
                    color: elevatedButtonBackgroundColor,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Пока нет упражнений',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Добавь первое упражнение для своей тренировки',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: List.generate(exercises.length, (index) {
                final exercise = exercises[index];
                final approachCount = exercise.approaches.length;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Dismissible(
                    key: ValueKey('${exercise.name}-$index'),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _deleteExercise(index),
                    background: Container(
                      decoration: BoxDecoration(
                        color: _dangerColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () => _openExercise(exercise),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _borderSoft),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.035),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _softTileColor,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.fitness_center_rounded,
                                color: _textPrimary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                exercise.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: _textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              approachCount == 0
                                  ? 'без подходов'
                                  : '$approachCount ${_getApproachWord(approachCount)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: _textSecondary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: _textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
  color: Colors.transparent, // 👈 ВОТ ЭТО
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
  onPressed: _finishTraining,
  style: OutlinedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: _textPrimary,
    side: BorderSide(color: _borderSoft),
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
                child: const Text(
                  'Завершить',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
  onPressed: _openExerciseBottomSheet,
  style: ElevatedButton.styleFrom(
    backgroundColor: elevatedButtonBackgroundColor,
    foregroundColor: elevatedButtonForegroundColor,
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Добавить упражнение',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldBlock({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

Widget _buildInputField({
  required TextEditingController controller,
  required String hintText,
  ValueChanged<String>? onChanged,
  FocusNode? focusNode,
  double fontSize = 16,
  FontWeight fontWeight = FontWeight.w500,
}) {
  final isFocused = focusNode?.hasFocus ?? false;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 150),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isFocused
            ? inputOutlineBorderColor
            : inputOutlineBorderColor.withOpacity(0.4),
        width: 1.5,
      ),
    ),
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      focusNode: focusNode,
      style: TextStyle(
        color: _textPrimary,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: hintTextForegroundColor,
          fontSize: fontSize,
        ),

        // 👇 ВОТ ЭТО КЛЮЧ
        filled: true,
        fillColor: Colors.white,

        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    ),
  );
}
Future<void> _handleBack() async {
  final trainingName = _trainingNameController.text.trim();
  final hasContent =
      exercises.isNotEmpty ||
      _trainingDescriptionController.text.trim().isNotEmpty;

  if (!hasContent) {
    if (!mounted) return;
    Navigator.pop(context);
    return;
  }

  if (trainingName.isEmpty) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Сначала введите название тренировки'),
      ),
    );
    return;
  }

  await _saveCurrentTrainingState();

  if (!mounted) return;
  Navigator.pop(context);
}

  Widget _buildModalInputField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _inputColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderSoft),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: _textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: _textSecondary,
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}