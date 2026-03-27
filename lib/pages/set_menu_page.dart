import 'package:flutter/material.dart';
import 'package:dp/colors.dart';
import '../models/training_models.dart';

class SetMenuScreen extends StatefulWidget {
  final String exerciseName;
  final List<Approach> initialApproaches;

  const SetMenuScreen({
    super.key,
    required this.exerciseName,
    this.initialApproaches = const [],
  });

  @override
  State<SetMenuScreen> createState() => _SetMenuScreenState();
}

class _SetMenuScreenState extends State<SetMenuScreen> {
  bool get _isApproachFormValid {
  final reps = _parseReps();
  final weight = _parseWeight();

  return reps != null &&
      reps >= 1 &&
      reps <= 1000 &&
      weight != null &&
      weight >= 0.5 &&
      weight <= 500;
}
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();

  List<Approach> _approaches = [];
  int? _editingIndex;

  String? _repsError;
  String? _weightError;

  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _cardBorder = Color(0xFFE7E5E4);
  static const Color _cardColor = Colors.white;
  static const Color _softColor = Color(0xFFFFFBF5);

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
    _repsError = null;
    _weightError = null;
    _showApproachBottomSheet();
  }

  void _openEditApproachDialog(int index) {
    _editingIndex = index;
    final approach = _approaches[index];
    _repsController.text = approach.reps;
    _weightController.text = approach.weight;
    _repsError = null;
    _weightError = null;
    _showApproachBottomSheet();
  }

  int? _parseReps() {
    final value = _repsController.text.trim();
    if (value.isEmpty) return null;
    return int.tryParse(value);
  }

  double? _parseWeight() {
    final value = _weightController.text.trim().replaceAll(',', '.');
    if (value.isEmpty) return null;
    return double.tryParse(value);
  }

  bool _validateApproachForm(StateSetter modalSetState) {
    final reps = _parseReps();
    final weight = _parseWeight();

    String? newRepsError;
    String? newWeightError;

    if (_repsController.text.trim().isEmpty) {
      newRepsError = 'Введите количество повторений';
    } else if (reps == null) {
      newRepsError = 'Повторения должны быть целым числом';
    } else if (reps < 1 || reps > 1000) {
      newRepsError = 'Повторения должны быть от 1 до 1000';
    }

    if (_weightController.text.trim().isEmpty) {
      newWeightError = 'Введите вес';
    } else if (weight == null) {
      newWeightError = 'Введите корректный вес';
    } else if (weight < 0.5 || weight > 500) {
      newWeightError = 'Вес должен быть от 0.5 до 500 кг';
    }

    modalSetState(() {
      _repsError = newRepsError;
      _weightError = newWeightError;
    });

    return newRepsError == null && newWeightError == null;
  }

  void _showApproachBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
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
                    Text(
                      _editingIndex == null
                          ? 'Добавить подход'
                          : 'Редактировать подход',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Укажи количество повторений и рабочий вес',
                      style: TextStyle(
                        fontSize: 15,
                        color: _textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildBottomSheetField(
                      controller: _repsController,
                      hintText: 'Количество повторений',
                      icon: Icons.repeat_rounded,
                      errorText: _repsError,
                      keyboardType: TextInputType.number,
                      onChanged: (_) {
  modalSetState(() {
    if (_repsError != null) {
      _repsError = null;
    }
  });
},
                    ),
                    const SizedBox(height: 12),
                    _buildBottomSheetField(
                      controller: _weightController,
                      hintText: 'Вес (кг)',
                      icon: Icons.fitness_center_rounded,
                      errorText: _weightError,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) {
  modalSetState(() {
    if (_weightError != null) {
      _weightError = null;
    }
  });
},
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
  onPressed: _isApproachFormValid
      ? () {
          if (!_validateApproachForm(modalSetState)) return;

          if (_editingIndex == null) {
            _addApproach();
          } else {
            _updateApproach(_editingIndex!);
          }

          Navigator.of(bottomSheetContext).pop();
        }
      : null,
  style: ElevatedButton.styleFrom(
    backgroundColor: elevatedButtonBackgroundColor,
    foregroundColor: elevatedButtonForegroundColor,
    disabledBackgroundColor:
        elevatedButtonBackgroundColor.withOpacity(0.45),
    disabledForegroundColor:
        elevatedButtonForegroundColor.withOpacity(0.7),
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
  ),
  child: const Text(
    'Сохранить подход',
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
      },
    );
  }

  Widget _buildBottomSheetField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    String? errorText,
    TextInputType keyboardType = TextInputType.number,
    ValueChanged<String>? onChanged,
  }) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: inputInnerColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: hasError ? Colors.red : inputOutlineBorderColor,
              width: hasError ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: hintTextForegroundColor,
                fontSize: 16,
              ),
              prefixIcon: Icon(
                icon,
                color: _textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _addApproach() {
    setState(() {
      _approaches.add(
        Approach(
          reps: _repsController.text.trim(),
          weight: _weightController.text.trim().replaceAll(',', '.'),
        ),
      );
    });
  }

  void _updateApproach(int index) {
    setState(() {
      _approaches[index] = Approach(
        reps: _repsController.text.trim(),
        weight: _weightController.text.trim().replaceAll(',', '.'),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              _buildCustomHeader(),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Expanded(
                child: _approaches.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: _approaches.length,
                        itemBuilder: (context, index) {
                          final approach = _approaches[index];

                          return Dismissible(
                            key: ValueKey(
                              '$index-${approach.reps}-${approach.weight}',
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              _deleteApproach(index);
                            },
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.white,
                              ),
                            ),
                            child: GestureDetector(
                              onTap: () => _openEditApproachDialog(index),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _cardColor,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: _cardBorder),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 14,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: _softColor,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: _textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Подход ${index + 1}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: _textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${approach.reps} повторений · ${approach.weight} кг',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: _textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.edit_outlined,
                                      color: _textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _openAddApproachDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: elevatedButtonBackgroundColor,
                    foregroundColor: elevatedButtonForegroundColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(
                    'Добавить подход',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final topSpacing = (screenHeight * 0.015).clamp(8.0, 18.0);
    final headerHeight = (screenHeight * 0.065).clamp(48.0, 64.0);
    final backButtonSize = (screenWidth * 0.11).clamp(40.0, 48.0);
    final iconSize = (screenWidth * 0.065).clamp(22.0, 30.0);
    final titleFontSize = (screenWidth * 0.06).clamp(20.0, 26.0);

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
                onTap: _returnResult,
                child: Container(
                  width: backButtonSize,
                  height: backButtonSize,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
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
                widget.exerciseName,
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

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _softColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.repeat_rounded,
                size: 34,
                color: elevatedButtonBackgroundColor,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Пока нет подходов',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Добавь первый подход для этого упражнения',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: _textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}