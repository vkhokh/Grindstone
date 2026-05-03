import 'package:dp/colors.dart';
import 'package:dp/services/user_session_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/exercise_catalog_item.dart';
import '../models/training_models.dart';
import '../utils/input_limits.dart';

class SetMenuScreen extends StatefulWidget {
  final String exerciseName;
  final ExerciseTrackingType trackingType;
  final List<Approach> initialApproaches;

  const SetMenuScreen({
    super.key,
    required this.exerciseName,
    required this.trackingType,
    this.initialApproaches = const [],
  });

  @override
  State<SetMenuScreen> createState() => _SetMenuScreenState();
}

class _SetMenuScreenState extends State<SetMenuScreen> {
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _additionalWeightController = TextEditingController();
  final _minutesController = TextEditingController();
  final _secondsController = TextEditingController();

  List<Approach> _approaches = [];
  int? _editingIndex;

  double? _profileWeightKg;
  bool _isLoadingProfile = true;

  String? _repsError;
  String? _weightError;
  String? _additionalWeightError;
  String? _durationError;

  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _cardBorder = Color(0xFFE7E5E4);
  static const Color _cardColor = Colors.white;
  static const Color _softColor = Color(0xFFFFFBF5);
  static const Color _hintTextColor = Color(0xFF9CA3AF);

  @override
  void initState() {
    super.initState();
    _approaches = List.from(widget.initialApproaches);
    _loadProfileWeight();
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    _additionalWeightController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileWeight() async {
    final profile = await UserSessionStorage.loadProfile();
    if (!mounted) return;

    setState(() {
      _profileWeightKg = profile.weightKg;
      _isLoadingProfile = false;
    });
  }

  void _returnResult() {
    Navigator.pop(context, _approaches);
  }

  void _openAddApproachDialog() {
    _editingIndex = null;
    _clearFields();
    _showApproachBottomSheet();
  }

  void _openEditApproachDialog(int index) {
    _editingIndex = index;
    final approach = _approaches[index];

    _repsController.text = approach.reps?.toString() ?? '';
    _weightController.text = _formatDouble(approach.weightKg);
    _additionalWeightController.text = _formatDouble(
      approach.additionalWeightKg,
    );

    final totalSeconds = approach.durationSeconds ?? 0;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    _minutesController.text = minutes == 0 ? '' : minutes.toString();
    _secondsController.text = seconds == 0 ? '' : seconds.toString();

    _clearErrors();
    _showApproachBottomSheet();
  }

  void _clearFields() {
    _repsController.clear();
    _weightController.clear();
    _additionalWeightController.clear();
    _minutesController.clear();
    _secondsController.clear();
    _clearErrors();
  }

  void _clearErrors() {
    _repsError = null;
    _weightError = null;
    _additionalWeightError = null;
    _durationError = null;
  }

  String _formatDouble(double? value) {
    if (value == null) return '';
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
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

  double? _parseAdditionalWeight() {
    final value = _additionalWeightController.text.trim().replaceAll(',', '.');
    if (value.isEmpty) return 0;
    return double.tryParse(value);
  }

  int _parseDurationSeconds() {
    final minutes = int.tryParse(_minutesController.text.trim()) ?? 0;
    final seconds = int.tryParse(_secondsController.text.trim()) ?? 0;
    return (minutes * 60) + seconds;
  }

  bool get _isApproachFormValid {
    if (widget.trackingType == ExerciseTrackingType.weightReps) {
      final reps = _parseReps();
      final weight = _parseWeight();
      return reps != null &&
          reps >= 1 &&
          reps <= 1000 &&
          weight != null &&
          weight >= 0.5 &&
          weight <= 500;
    }

    if (widget.trackingType == ExerciseTrackingType.bodyweightReps) {
      final reps = _parseReps();
      final additionalWeight = _parseAdditionalWeight();
      return reps != null &&
          reps >= 1 &&
          reps <= 1000 &&
          additionalWeight != null &&
          additionalWeight >= 0 &&
          additionalWeight <= 500 &&
          _profileWeightKg != null;
    }

    final seconds = int.tryParse(_secondsController.text.trim()) ?? 0;
    final totalSeconds = _parseDurationSeconds();
    return seconds <= 59 && totalSeconds > 0 && totalSeconds <= 24 * 60 * 60;
  }

  bool _validateApproachForm(StateSetter modalSetState) {
    String? newRepsError;
    String? newWeightError;
    String? newAdditionalWeightError;
    String? newDurationError;

    if (widget.trackingType == ExerciseTrackingType.weightReps) {
      final reps = _parseReps();
      final weight = _parseWeight();

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
    }

    if (widget.trackingType == ExerciseTrackingType.bodyweightReps) {
      final reps = _parseReps();
      final additionalWeight = _parseAdditionalWeight();

      if (_repsController.text.trim().isEmpty) {
        newRepsError = 'Введите количество повторений';
      } else if (reps == null) {
        newRepsError = 'Повторения должны быть целым числом';
      } else if (reps < 1 || reps > 1000) {
        newRepsError = 'Повторения должны быть от 1 до 1000';
      }

      if (additionalWeight == null) {
        newAdditionalWeightError = 'Введите корректный дополнительный вес';
      } else if (additionalWeight < 0 || additionalWeight > 500) {
        newAdditionalWeightError = 'Доп. вес должен быть от 0 до 500 кг';
      }

      if (_profileWeightKg == null) {
        newWeightError = 'В профиле не указан вес пользователя';
      }
    }

    if (widget.trackingType == ExerciseTrackingType.duration) {
      final seconds = int.tryParse(_secondsController.text.trim()) ?? 0;
      final totalSeconds = _parseDurationSeconds();

      if (seconds > 59) {
        newDurationError = 'Секунды должны быть от 0 до 59';
      } else if (totalSeconds <= 0) {
        newDurationError = 'Введите время больше 0 секунд';
      } else if (totalSeconds > 24 * 60 * 60) {
        newDurationError = 'Слишком большое время';
      }
    }

    modalSetState(() {
      _repsError = newRepsError;
      _weightError = newWeightError;
      _additionalWeightError = newAdditionalWeightError;
      _durationError = newDurationError;
    });

    return newRepsError == null &&
        newWeightError == null &&
        newAdditionalWeightError == null &&
        newDurationError == null;
  }

  void _addApproach() {
    late final Approach approach;

    if (widget.trackingType == ExerciseTrackingType.weightReps) {
      approach = Approach(reps: _parseReps(), weightKg: _parseWeight());
    } else if (widget.trackingType == ExerciseTrackingType.bodyweightReps) {
      approach = Approach(
        reps: _parseReps(),
        isBodyweight: true,
        bodyweightKgSnapshot: _profileWeightKg,
        additionalWeightKg: _parseAdditionalWeight(),
      );
    } else {
      approach = Approach(durationSeconds: _parseDurationSeconds());
    }

    setState(() {
      _approaches.add(approach);
    });
  }

  void _updateApproach(int index) {
    late final Approach approach;

    if (widget.trackingType == ExerciseTrackingType.weightReps) {
      approach = Approach(reps: _parseReps(), weightKg: _parseWeight());
    } else if (widget.trackingType == ExerciseTrackingType.bodyweightReps) {
      approach = Approach(
        reps: _parseReps(),
        isBodyweight: true,
        bodyweightKgSnapshot: _profileWeightKg,
        additionalWeightKg: _parseAdditionalWeight(),
      );
    } else {
      approach = Approach(durationSeconds: _parseDurationSeconds());
    }

    setState(() {
      _approaches[index] = approach;
    });
  }

  void _deleteApproach(int index) {
    setState(() {
      _approaches.removeAt(index);
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = remainingSeconds.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  String _approachSubtitle(Approach approach) {
    if (widget.trackingType == ExerciseTrackingType.weightReps) {
      return '${approach.reps ?? 0} повторений · ${_formatDouble(approach.weightKg)} кг';
    }

    if (widget.trackingType == ExerciseTrackingType.bodyweightReps) {
      final body = _formatDouble(approach.bodyweightKgSnapshot);
      final add = _formatDouble(approach.additionalWeightKg ?? 0);
      return '${approach.reps ?? 0} повторений · вес тела $body кг · доп. $add кг';
    }

    return _formatDuration(approach.durationSeconds ?? 0);
  }

  String _sheetSubtitle() {
    switch (widget.trackingType) {
      case ExerciseTrackingType.weightReps:
        return 'Укажи количество повторений и рабочий вес';
      case ExerciseTrackingType.bodyweightReps:
        return 'Укажи повторения, вес тела подтянется из профиля';
      case ExerciseTrackingType.duration:
        return 'Укажи длительность упражнения';
    }
  }

  void _saveApproach(StateSetter modalSetState) {
    if (!_validateApproachForm(modalSetState)) return;

    if (_editingIndex == null) {
      _addApproach();
    } else {
      _updateApproach(_editingIndex!);
    }

    Navigator.pop(context);
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
                bottom:
                    MediaQuery.of(bottomSheetContext).viewInsets.bottom + 16,
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
                    Text(
                      _sheetSubtitle(),
                      style: const TextStyle(
                        fontSize: 15,
                        color: _textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (widget.trackingType ==
                        ExerciseTrackingType.weightReps) ...[
                      _buildBottomSheetField(
                        controller: _repsController,
                        hintText: 'Количество повторений',
                        icon: Icons.repeat_rounded,
                        errorText: _repsError,
                        keyboardType: TextInputType.number,
                        maxLength: AppInputLimits.reps,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (_) {
                          modalSetState(() {
                            if (_repsError != null) _repsError = null;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildBottomSheetField(
                        controller: _weightController,
                        hintText: 'Вес (кг)',
                        icon: Icons.fitness_center_rounded,
                        errorText: _weightError,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        maxLength: AppInputLimits.weight,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        onChanged: (_) {
                          modalSetState(() {
                            if (_weightError != null) _weightError = null;
                          });
                        },
                      ),
                    ],
                    if (widget.trackingType ==
                        ExerciseTrackingType.bodyweightReps) ...[
                      _buildBottomSheetField(
                        controller: _repsController,
                        hintText: 'Количество повторений',
                        icon: Icons.repeat_rounded,
                        errorText: _repsError,
                        keyboardType: TextInputType.number,
                        maxLength: AppInputLimits.reps,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (_) {
                          modalSetState(() {
                            if (_repsError != null) _repsError = null;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildInfoTile(
                        title: 'Вес тела',
                        value: _isLoadingProfile
                            ? 'Загрузка...'
                            : _profileWeightKg == null
                            ? 'Не указан в профиле'
                            : '${_formatDouble(_profileWeightKg)} кг',
                        errorText: _weightError,
                      ),
                      const SizedBox(height: 12),
                      _buildBottomSheetField(
                        controller: _additionalWeightController,
                        hintText: 'Дополнительный вес (кг)',
                        icon: Icons.add_circle_outline_rounded,
                        errorText: _additionalWeightError,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        maxLength: AppInputLimits.weight,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        onChanged: (_) {
                          modalSetState(() {
                            if (_additionalWeightError != null) {
                              _additionalWeightError = null;
                            }
                          });
                        },
                      ),
                    ],
                    if (widget.trackingType ==
                        ExerciseTrackingType.duration) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildBottomSheetField(
                              controller: _minutesController,
                              hintText: 'Минуты',
                              icon: Icons.timer_outlined,
                              errorText: null,
                              keyboardType: TextInputType.number,
                              maxLength: AppInputLimits.durationMinutes,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (_) {
                                modalSetState(() {
                                  if (_durationError != null) {
                                    _durationError = null;
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildBottomSheetField(
                              controller: _secondsController,
                              hintText: 'Секунды',
                              icon: Icons.timelapse_rounded,
                              errorText: null,
                              keyboardType: TextInputType.number,
                              maxLength: AppInputLimits.durationSeconds,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (_) {
                                modalSetState(() {
                                  if (_durationError != null) {
                                    _durationError = null;
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      if (_durationError != null) ...[
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            _durationError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isApproachFormValid
                            ? () => _saveApproach(modalSetState)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: elevatedButtonBackgroundColor,
                          foregroundColor: Colors.black,
                          disabledBackgroundColor: elevatedButtonBackgroundColor
                              .withOpacity(0.45),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _editingIndex == null ? 'Добавить' : 'Сохранить',
                          style: const TextStyle(
                            fontSize: 16,
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

  Widget _buildInfoTile({
    required String title,
    required String value,
    String? errorText,
  }) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: _softColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: hasError ? Colors.red : _cardBorder,
              width: hasError ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              const Icon(Icons.person_outline_rounded, color: _textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

  Widget _buildBottomSheetField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required String? errorText,
    required TextInputType keyboardType,
    required ValueChanged<String> onChanged,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: _softColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: hasError ? Colors.red : _cardBorder,
              width: hasError ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            buildCounter: hiddenMaxLengthCounter,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: _hintTextColor, fontSize: 16),
              prefixIcon: Icon(icon, color: _textSecondary),
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
    String subtitle;

    switch (widget.trackingType) {
      case ExerciseTrackingType.weightReps:
        subtitle = 'Добавь первый подход для этого упражнения';
        break;
      case ExerciseTrackingType.bodyweightReps:
        subtitle = 'Добавь первый подход с собственным весом';
        break;
      case ExerciseTrackingType.duration:
        subtitle = 'Добавь первый подход по времени';
        break;
    }

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
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: _textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApproachCard(Approach approach, int index) {
    return Dismissible(
      key: ValueKey(
        '$index-${approach.reps}-${approach.weightKg}-${approach.durationSeconds}',
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
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
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
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Подход ${index + 1}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _approachSubtitle(approach),
                      style: const TextStyle(
                        fontSize: 15,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.edit_outlined, color: _textSecondary),
            ],
          ),
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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              _buildCustomHeader(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Expanded(
                child: _approaches.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: _approaches.length,
                        itemBuilder: (context, index) {
                          final approach = _approaches[index];
                          return _buildApproachCard(approach, index);
                        },
                      ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _openAddApproachDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: elevatedButtonBackgroundColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Добавить подход',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
