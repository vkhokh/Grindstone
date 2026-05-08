import 'dart:convert';

import 'package:dp/colors.dart';
import 'package:dp/models/exercise_catalog_item.dart';
import 'package:dp/models/workout_progress.dart';
import 'package:dp/pages/current_training_page.dart';
import 'package:dp/pages/profile_page.dart';
import 'package:dp/pages/progress_page.dart';
import 'package:dp/pages/training_archive_page.dart';
import 'package:dp/services/workout_progress_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/training_models.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  FullTrainingData? _currentTrainingData;

  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _cardColor = Color(0xFFFFFBF5);
  static const Color _softTileColor = Color(0xFFFCF7EF);
  static const Color _borderSoft = Color(0xFFE8E2D6);
  static const Color _navBackground = Color(0xFFF2EAD9);
  static const Color _completedGreen = Color(0xFF2EAD4A);
  static const Color _completedGreenSoft = Color(0xFFEAF7EE);

  @override
  void initState() {
    super.initState();
    _loadCurrentTraining();
    WorkoutProgressService.instance.ensureProgressData();
  }

  bool _hasCurrentTrainingDraft(FullTrainingData data) {
    return data.basicInfo.name.trim().isNotEmpty ||
        data.basicInfo.description.trim().isNotEmpty ||
        data.exercises.isNotEmpty;
  }

  Future<void> _loadCurrentTraining() async {
    final prefs = await SharedPreferences.getInstance();
    final trainingString = prefs.getString('current_training');

    if (!mounted) return;

    if (trainingString != null) {
      try {
        final jsonMap = jsonDecode(trainingString) as Map<String, dynamic>;
        final fullData = FullTrainingData.fromJson(jsonMap);

        setState(() {
          _currentTrainingData = _hasCurrentTrainingDraft(fullData)
              ? fullData
              : null;
        });
      } catch (_) {
        setState(() {
          _currentTrainingData = null;
        });
      }
    } else {
      setState(() {
        _currentTrainingData = null;
      });
    }
  }

  Future<void> _openCurrentTraining() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CurrentWorkoutScreen(),
      ),
    );

    if (!mounted) return;
    _loadCurrentTraining();
  }

  Future<void> _startNewTraining() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_training');

    if (!mounted) return;

    setState(() {
      _currentTrainingData = null;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CurrentWorkoutScreen(),
      ),
    );

    if (!mounted) return;
    _loadCurrentTraining();
  }

  void _openProgressPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ProgressPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasCurrentTraining = _currentTrainingData != null;

    return Scaffold(
      backgroundColor: backGroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 18),
              Expanded(
                child: StreamBuilder<WorkoutProgressOverview>(
                  stream: WorkoutProgressService.instance.watchOverview(),
                  builder: (context, overviewSnapshot) {
                    final overview = overviewSnapshot.data ??
                        const WorkoutProgressOverview.empty();

                    return StreamBuilder<List<ExerciseProgressSummary>>(
                      stream:
                          WorkoutProgressService.instance.watchExerciseSummaries(),
                      builder: (context, summarySnapshot) {
                        final summaries = summarySnapshot.data ??
                            const <ExerciseProgressSummary>[];

                        return _buildHomeContent(
                          hasCurrentTraining: hasCurrentTraining,
                          overview: overview,
                          summaries: summaries,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHomeContent({
    required bool hasCurrentTraining,
    required WorkoutProgressOverview overview,
    required List<ExerciseProgressSummary> summaries,
  }) {
    final hasProgress = overview.totalTrainings > 0 || summaries.isNotEmpty;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          if (hasCurrentTraining)
            _buildActiveTrainingCard()
          else
            _buildStartCard(
              overview: overview,
              summaries: summaries,
              hasProgress: hasProgress,
            ),
          const SizedBox(height: 16),
          if (hasProgress) ...[
            _buildProgressSnapshotCard(overview, summaries),
            const SizedBox(height: 16),
            _buildBestResultsHomeCard(summaries),
          ] else
            _buildEmptyProgressCard(),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final titleFontSize = (screenWidth * 0.08).clamp(26.0, 32.0);

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Добро пожаловать',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildStartCard({
    required WorkoutProgressOverview overview,
    required List<ExerciseProgressSummary> summaries,
    required bool hasProgress,
  }) {
    final bestImproved = _bestImprovedExercise(summaries);
    final lastCompleted = overview.lastCompletedAt;

    final title = hasProgress ? 'Готов к новой тренировке?' : 'Начни первую тренировку';
    final subtitle = hasProgress
        ? 'Последняя тренировка была ${_relativeDateLabel(lastCompleted)}. Можно начать новую или открыть прогресс ниже.'
        : 'Добавляй упражнения, отмечай выполненные подходы и следи за прогрессом.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(28),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: elevatedButtonBackgroundColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  hasProgress
                      ? Icons.local_fire_department_rounded
                      : Icons.fitness_center_rounded,
                  color: elevatedButtonBackgroundColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 15,
                        color: _textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasProgress) ...[
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildInfoChip(
                  icon: Icons.archive_rounded,
                  text: '${overview.totalTrainings} ${_pluralTrainings(overview.totalTrainings)}',
                ),
                _buildInfoChip(
                  icon: Icons.fitness_center_rounded,
                  text: '${overview.uniqueExercises} ${_pluralExercises(overview.uniqueExercises)}',
                ),
                if (bestImproved != null)
                  _buildInfoChip(
                    icon: Icons.trending_up_rounded,
                    text:
                        '${_shortExerciseName(bestImproved.exerciseName)} ${_trendLabel(bestImproved)}',
                  ),
              ],
            ),
          ],
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startNewTraining,
              style: ElevatedButton.styleFrom(
                backgroundColor: elevatedButtonBackgroundColor,
                foregroundColor: elevatedButtonForegroundColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                hasProgress ? 'Начать новую тренировку' : 'Создать тренировку',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTrainingCard() {
    final training = _currentTrainingData!;
    final exercises = training.exercises;
    final exerciseCount = exercises.length;
    final trainingName = training.basicInfo.name.trim().isEmpty
        ? 'Тренировка без названия'
        : training.basicInfo.name.trim();

    final totalApproaches = _totalApproaches(training);
    final completedApproaches = _completedApproaches(training);
    final progress = totalApproaches == 0 ? 0.0 : completedApproaches / totalApproaches;
    final isCompleted = totalApproaches > 0 && completedApproaches == totalApproaches;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(28),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  isCompleted ? 'Тренировка выполнена' : 'Текущая тренировка',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isCompleted ? _completedGreen : _textSecondary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? _completedGreenSoft
                      : elevatedButtonBackgroundColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_rounded
                      : Icons.local_fire_department_rounded,
                  color: isCompleted
                      ? _completedGreen
                      : elevatedButtonBackgroundColor,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            trainingName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildInfoChip(
                icon: Icons.fitness_center_rounded,
                text: '$exerciseCount ${_pluralExercises(exerciseCount)}',
              ),
              _buildInfoChip(
                icon: Icons.repeat_rounded,
                text: '$totalApproaches ${_pluralApproaches(totalApproaches)}',
              ),
            ],
          ),
          if (totalApproaches > 0) ...[
            const SizedBox(height: 18),
            _buildTrainingProgress(
              completed: completedApproaches,
              total: totalApproaches,
              progress: progress,
              isCompleted: isCompleted,
            ),
          ],
          const SizedBox(height: 20),
          if (exercises.isEmpty)
            _buildNoExercisesBlock()
          else
            Column(
              children: exercises.take(4).map(_buildExercisePreviewCard).toList(),
            ),
          if (exercises.length > 4) ...[
            const SizedBox(height: 2),
            Text(
              'И ещё ${exercises.length - 4} ${_pluralExercises(exercises.length - 4)}',
              style: const TextStyle(
                fontSize: 14,
                color: _textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openCurrentTraining,
              style: ElevatedButton.styleFrom(
                backgroundColor: isCompleted
                    ? _completedGreen
                    : elevatedButtonBackgroundColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                isCompleted ? 'Открыть тренировку' : 'Продолжить тренировку',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSnapshotCard(
    WorkoutProgressOverview overview,
    List<ExerciseProgressSummary> summaries,
  ) {
    final bestImproved = _bestImprovedExercise(summaries);
    final bestResult = _bestResultExercise(summaries);

    return GestureDetector(
      onTap: _openProgressPage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: _borderSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: elevatedButtonBackgroundColor.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.insights_rounded,
                    color: elevatedButtonBackgroundColor,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Твой прогресс',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: _textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInsightRow(
              icon: Icons.archive_rounded,
              title: 'В архиве',
              value:
                  '${overview.totalTrainings} ${_pluralTrainings(overview.totalTrainings)}',
            ),
            const SizedBox(height: 12),
            _buildInsightRow(
              icon: Icons.trending_up_rounded,
              title: bestImproved == null ? 'Рост' : 'Лучший рост',
              value: bestImproved == null
                  ? 'Пока без изменений'
                  : '${_shortExerciseName(bestImproved.exerciseName)} ${_trendLabel(bestImproved)}',
            ),
            const SizedBox(height: 12),
            _buildInsightRow(
              icon: Icons.emoji_events_rounded,
              title: bestResult == null ? 'Лучший результат' : bestResult.exerciseName,
              value: bestResult == null
                  ? 'Появится после тренировок'
                  : _bestResultLabel(bestResult),
            ),
            const SizedBox(height: 12),
            _buildInsightRow(
              icon: Icons.calendar_today_rounded,
              title: 'Последняя тренировка',
              value: _shortDateLabel(overview.lastCompletedAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestResultsHomeCard(List<ExerciseProgressSummary> summaries) {
    final visible = [...summaries]
      ..sort((a, b) => b.personalBestValue.compareTo(a.personalBestValue));

    final top = visible.take(3).toList();
    if (top.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardColor.withOpacity(0.78),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Лучшие результаты',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...top.map((summary) {
            final isLast = summary == top.last;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: elevatedButtonBackgroundColor.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.fitness_center_rounded,
                      color: elevatedButtonBackgroundColor,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      summary.exerciseName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _bestResultValueLabel(summary),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInsightRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _softTileColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderSoft),
          ),
          child: Icon(icon, size: 18, color: _textPrimary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyProgressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardColor.withOpacity(0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _borderSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: elevatedButtonBackgroundColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.trending_up_rounded,
              color: elevatedButtonBackgroundColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Прогресс появится после архива',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Заверши и сохрани тренировку — здесь появятся лучшие результаты и динамика.',
                  style: TextStyle(
                    fontSize: 14,
                    color: _textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingProgress({
    required int completed,
    required int total,
    required double progress,
    required bool isCompleted,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? _completedGreenSoft : _softTileColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? _completedGreen.withOpacity(0.35)
              : _borderSoft,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isCompleted
                      ? 'Все подходы выполнены'
                      : '$completed из $total подходов выполнено',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isCompleted ? _completedGreen : _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.7),
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? _completedGreen : elevatedButtonBackgroundColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoExercisesBlock() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: _softTileColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center_rounded,
            size: 34,
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
            'Открой тренировку и добавь первое упражнение.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisePreviewCard(Exercise exercise) {
    final total = exercise.approaches.length;
    final completed = exercise.approaches
        .where((approach) => approach.isCompleted)
        .length;
    final progress = total == 0 ? 0.0 : completed / total;
    final isCompleted = total > 0 && completed == total;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? _completedGreenSoft : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? _completedGreen.withOpacity(0.4)
              : _borderSoft,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.white : _softTileColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isCompleted
                  ? Icons.check_rounded
                  : Icons.fitness_center_rounded,
              color: isCompleted ? _completedGreen : _textPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        exercise.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      total == 0
                          ? '0%'
                          : isCompleted
                              ? 'Готово'
                              : '${(progress * 100).round()}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isCompleted ? _completedGreen : _textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  total == 0
                      ? 'Подходы ещё не добавлены'
                      : '$completed из $total подходов выполнено',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textSecondary,
                  ),
                ),
                if (total > 0) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: _softTileColor,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted
                            ? _completedGreen
                            : elevatedButtonBackgroundColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
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

  int _totalApproaches(FullTrainingData training) {
    return training.exercises.fold<int>(
      0,
      (sum, exercise) => sum + exercise.approaches.length,
    );
  }

  int _completedApproaches(FullTrainingData training) {
    return training.exercises.fold<int>(
      0,
      (sum, exercise) =>
          sum + exercise.approaches.where((approach) => approach.isCompleted).length,
    );
  }

  ExerciseProgressSummary? _bestImprovedExercise(
    List<ExerciseProgressSummary> summaries,
  ) {
    final improved = summaries
        .where((summary) => summary.improvementValue > 0.001)
        .toList()
      ..sort((a, b) => b.improvementValue.compareTo(a.improvementValue));

    if (improved.isEmpty) return null;
    return improved.first;
  }

  ExerciseProgressSummary? _bestResultExercise(
    List<ExerciseProgressSummary> summaries,
  ) {
    if (summaries.isEmpty) return null;

    final sorted = [...summaries]
      ..sort((a, b) => b.personalBestValue.compareTo(a.personalBestValue));

    return sorted.first;
  }

  String _trendLabel(ExerciseProgressSummary summary) {
    final value = summary.improvementValue;

    if (value > 0.001) {
      return '+${_formatWeight(value)}';
    }

    if (value < -0.001) {
      return '-${_formatWeight(value.abs())}';
    }

    return 'без изменений';
  }

  String _bestResultLabel(ExerciseProgressSummary summary) {
    return 'Лучший результат ${_bestResultValueLabel(summary)}';
  }

  String _bestResultValueLabel(ExerciseProgressSummary summary) {
    switch (summary.trackingType) {
      case ExerciseTrackingType.weightReps:
      case ExerciseTrackingType.bodyweightReps:
        return _formatWeight(summary.personalBestValue);
      case ExerciseTrackingType.duration:
        return _formatDuration(summary.bestDurationSeconds ?? 0);
    }
  }

  String _formatWeight(double value) {
    if (value == value.roundToDouble()) {
      return '${value.toInt()} кг';
    }

    return '${value.toStringAsFixed(1).replaceAll('.', ',')} кг';
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (minutes == 0) {
      return '$remainingSeconds сек';
    }

    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _shortDateLabel(DateTime? date) {
    if (date == null) return 'Пока нет';

    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}';
  }

  String _relativeDateLabel(DateTime? date) {
    if (date == null) return 'недавно';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final local = date.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    final difference = today.difference(day).inDays;

    if (difference == 0) return 'сегодня';
    if (difference == 1) return 'вчера';

    return _shortDateLabel(date);
  }

  String _shortExerciseName(String name) {
    final trimmed = name.trim();
    if (trimmed.length <= 16) return trimmed;
    return '${trimmed.substring(0, 15)}…';
  }

  String _pluralTrainings(int count) {
    final mod10 = count % 10;
    final mod100 = count % 100;

    if (mod10 == 1 && mod100 != 11) return 'тренировка';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return 'тренировки';
    }
    return 'тренировок';
  }

  String _pluralExercises(int count) {
    final mod10 = count % 10;
    final mod100 = count % 100;

    if (mod10 == 1 && mod100 != 11) return 'упражнение';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return 'упражнения';
    }
    return 'упражнений';
  }

  String _pluralApproaches(int count) {
    final mod10 = count % 10;
    final mod100 = count % 100;

    if (mod10 == 1 && mod100 != 11) return 'подход';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return 'подхода';
    }
    return 'подходов';
  }

  Widget _buildBottomNavigation() {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: _navBackground,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTab(
                icon: Icons.home_rounded,
                label: 'Домой',
                isActive: true,
                onTap: null,
              ),
            ),
            Expanded(
              child: _buildTab(
                icon: Icons.view_list_rounded,
                label: 'Тренировки',
                isActive: false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrainingArchivePage(),
                    ),
                  );
                },
              ),
            ),
            _buildFloatingButton(),
            Expanded(
              child: _buildTab(
                icon: Icons.bar_chart_rounded,
                label: 'Прогресс',
                isActive: false,
                onTap: _openProgressPage,
              ),
            ),
            Expanded(
              child: _buildTab(
                icon: Icons.person_rounded,
                label: 'Профиль',
                isActive: false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback? onTap,
  }) {
    final color =
        isActive ? elevatedButtonBackgroundColor : const Color(0xFF6F6F74);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? elevatedButtonBackgroundColor.withOpacity(0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton() {
    return GestureDetector(
      onTap: _startNewTraining,
      child: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: elevatedButtonBackgroundColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: elevatedButtonBackgroundColor.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
