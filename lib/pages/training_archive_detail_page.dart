import 'package:dp/colors.dart';
import 'package:flutter/material.dart';

import '../models/archived_training.dart';
import '../models/training_models.dart';

class TrainingArchiveDetailPage extends StatelessWidget {
  const TrainingArchiveDetailPage({
    super.key,
    required this.archivedTraining,
  });

  final ArchivedTraining archivedTraining;

  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _cardColor = Color(0xFFFFFBF5);
  static const Color _softTileColor = Color(0xFFFCF7EF);
  static const Color _borderSoft = Color(0xFFE8E2D6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildOverviewCard(),
                      const SizedBox(height: 18),
                      _buildExercisesSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _borderSoft),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: _textPrimary,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 56),
            child: Text(
              'Детали тренировки',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _borderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: elevatedButtonBackgroundColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _formatDate(archivedTraining.completedAt),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            archivedTraining.name,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            archivedTraining.description.isEmpty
                ? 'Описание не добавлено, но структура тренировки и все подходы сохранены в архиве.'
                : archivedTraining.description,
            style: const TextStyle(
              fontSize: 15,
              color: _textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildStatChip(
                icon: Icons.fitness_center_rounded,
                text:
                    '${archivedTraining.exerciseCount} ${_pluralize(archivedTraining.exerciseCount, 'упражнение', 'упражнения', 'упражнений')}',
              ),
              _buildStatChip(
                icon: Icons.repeat_rounded,
                text:
                    '${archivedTraining.approachCount} ${_pluralize(archivedTraining.approachCount, 'подход', 'подхода', 'подходов')}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _softTileColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: _textPrimary),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesSection() {
    final exercises = archivedTraining.exercises;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Упражнения и подходы',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (exercises.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _borderSoft),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 34,
                  color: _textSecondary,
                ),
                SizedBox(height: 12),
                Text(
                  'В этой тренировке пока нет упражнений',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: List.generate(
              exercises.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildExerciseCard(exercises[index], index),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExerciseCard(Exercise exercise, int index) {
    final approaches = exercise.approaches;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _borderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _softTileColor,
                  borderRadius: BorderRadius.circular(16),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      approaches.isEmpty
                          ? 'Подходы не добавлены'
                          : '${approaches.length} ${_pluralize(approaches.length, 'подход', 'подхода', 'подходов')}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (approaches.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _softTileColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'Для этого упражнения в архиве нет сохраненных подходов.',
                style: TextStyle(
                  fontSize: 14,
                  color: _textSecondary,
                ),
              ),
            )
          else
            Column(
              children: List.generate(
                approaches.length,
                (approachIndex) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildApproachRow(
                    approach: approaches[approachIndex],
                    index: approachIndex,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildApproachRow({
    required Approach approach,
    required int index,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderSoft),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: elevatedButtonBackgroundColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Подход',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
          ),
          _buildMetricPill(
            icon: Icons.repeat_rounded,
            label: '${approach.reps} раз',
          ),
          const SizedBox(width: 8),
          _buildMetricPill(
            icon: Icons.fitness_center_rounded,
            label: '${approach.weightKg} кг',
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _softTileColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _textPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return 'Сохранено недавно';
    }

    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day.$month.$year · $hour:$minute';
  }

  String _pluralize(int count, String one, String few, String many) {
    final remainder100 = count % 100;
    if (remainder100 >= 11 && remainder100 <= 19) {
      return many;
    }

    switch (count % 10) {
      case 1:
        return one;
      case 2:
      case 3:
      case 4:
        return few;
      default:
        return many;
    }
  }
}
