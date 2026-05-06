import 'dart:convert';

import 'package:dp/colors.dart';
import 'package:dp/pages/set_menu_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/exercise_catalog_item.dart';
import '../models/training_models.dart';
import '../services/workout_archive_service.dart';
import '../utils/input_limits.dart';
import '../widgets/exercise_picker_bottom_sheet.dart';

class CurrentWorkoutScreen extends StatefulWidget {
  const CurrentWorkoutScreen({super.key});

  @override
  State<CurrentWorkoutScreen> createState() => _CurrentWorkoutScreenState();
}

class _CurrentWorkoutScreenState extends State<CurrentWorkoutScreen> {
  List<Exercise> exercises = [];

  final TextEditingController _trainingNameController = TextEditingController();
  final TextEditingController _trainingDescriptionController =
      TextEditingController();

  final FocusNode _trainingNameFocusNode = FocusNode();
  final FocusNode _trainingDescriptionFocusNode = FocusNode();

  bool _isFinishing = false;

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
        _trainingDescriptionController.text = fullData.basicInfo.description;

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
    final hasAnyContent =
        trainingName.isNotEmpty ||
        trainingDescription.isNotEmpty ||
        exercises.isNotEmpty;

    if (!hasAnyContent) {
      await prefs.remove('current_training');
      return;
    }

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

  void _saveSelectedExercise(ExerciseCatalogItem item) {
    final alreadyExists = exercises.any(
      (exercise) =>
          exercise.exerciseId == item.id ||
          exercise.name.toLowerCase() == item.name.toLowerCase(),
    );

    if (alreadyExists) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Упражнение "${item.name}" уже добавлено')),
      );
      return;
    }

    setState(() {
      exercises.add(
        Exercise(
          name: item.name,
          exerciseId: item.id,
          trackingType: item.trackingType,
          approaches: [],
        ),
      );
    });

    _saveCurrentTrainingState();
  }

  Future<void> _openExercisePicker() async {
    final selectedExercise = await showModalBottomSheet<ExerciseCatalogItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ExercisePickerBottomSheet(),
    );

    if (selectedExercise == null) return;

    _saveSelectedExercise(selectedExercise);
  }

  void _deleteExercise(int index) {
    setState(() {
      exercises.removeAt(index);
    });
    _saveCurrentTrainingState();
  }

  FullTrainingData? _buildTrainingDataForArchive() {
    final trainingName = _trainingNameController.text.trim();
    if (trainingName.isEmpty) {
      return null;
    }

    return FullTrainingData(
      basicInfo: Training(
        name: trainingName,
        description: _trainingDescriptionController.text.trim(),
        hasTraining: true,
      ),
      exercises: exercises
          .map(
            (exercise) => Exercise(
              name: exercise.name,
              exerciseId: exercise.exerciseId,
              trackingType: exercise.trackingType,
              approaches: exercise.approaches
                  .map(
                    (approach) => Approach(
                      reps: approach.reps,
                      weightKg: approach.weightKg,
                      durationSeconds: approach.durationSeconds,
                      isBodyweight: approach.isBodyweight,
                      bodyweightKgSnapshot: approach.bodyweightKgSnapshot,
                      additionalWeightKg: approach.additionalWeightKg,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }

  Future<void> _finishTraining() async {
    if (_isFinishing) return;

    final hasAnyContent =
        _trainingNameController.text.trim().isNotEmpty ||
        _trainingDescriptionController.text.trim().isNotEmpty ||
        exercises.isNotEmpty;

    if (!hasAnyContent) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_training');

      if (!mounted) return;
      Navigator.pop(context);
      return;
    }

    final training = _buildTrainingDataForArchive();
    if (training == null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала введите название тренировки')),
      );
      return;
    }

    setState(() {
      _isFinishing = true;
    });

    try {
      await WorkoutArchiveService.instance.archiveTraining(training);

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_training');

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Не удалось сохранить тренировку в архив. Попробуйте снова.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isFinishing = false;
        });
      }
    }
  }

  Future<void> _openExercise(Exercise exercise) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SetMenuScreen(
          exerciseName: exercise.name,
          trackingType: exercise.trackingType,
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
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: _textPrimary,
                  size: 28,
                ),
              ),
            ),
          ),
          const Text(
            'Тренировка',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldBlock({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required ValueChanged<String> onChanged,
    required FocusNode focusNode,
    required double fontSize,
    required FontWeight fontWeight,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      maxLength: maxLength,
      buildCounter: hiddenMaxLengthCounter,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: _textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: _textSecondary.withOpacity(0.9),
        ),
        filled: true,
        fillColor: _inputColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.cyan.shade700, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.cyan.shade700, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.cyan.shade700, width: 1.6),
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
              maxLength: AppInputLimits.trainingName,
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
              maxLines: 1,
              maxLength: AppInputLimits.trainingDescription,
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
                    style: TextStyle(fontSize: 15, color: _textSecondary),
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
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              approachCount == 0
                                  ? '0'
                                  : '$approachCount ${_getApproachWord(approachCount)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _textSecondary,
                              ),
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

  Widget _buildBottomActionBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isFinishing ? null : _finishTraining,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _textPrimary,
                    disabledBackgroundColor: Colors.white70,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _isFinishing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: _textPrimary,
                          ),
                        )
                      : const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Завершить',
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 9,
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _openExercisePicker,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: elevatedButtonBackgroundColor,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 22),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Добавить упражнение',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      _buildTrainingInfoCard(),
                      const SizedBox(height: 14),
                      _buildExercisesCard(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }
}
