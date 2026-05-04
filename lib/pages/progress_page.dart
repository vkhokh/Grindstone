import 'package:dp/colors.dart';
import 'package:dp/models/archived_training.dart';
import 'package:dp/models/exercise_catalog_item.dart';
import 'package:dp/models/workout_progress.dart';
import 'package:dp/pages/current_training_page.dart';
import 'package:dp/pages/exercise_progress_detail_page.dart';
import 'package:dp/pages/main_page.dart';
import 'package:dp/pages/profile_page.dart';
import 'package:dp/pages/training_archive_page.dart';
import 'package:dp/services/workout_archive_service.dart';
import 'package:dp/services/workout_progress_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  bool _isRefreshing = false;

  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _cardColor = Color(0xFFFFFBF5);
  static const Color _softTileColor = Color(0xFFFCF7EF);
  static const Color _borderSoft = Color(0xFFE8E2D6);
  static const Color _navBackground = Color(0xFFF2EAD9);

  @override
  void initState() {
    super.initState();
    _bootstrapProgress();
  }

  Future<void> _bootstrapProgress() async {
    try {
      await WorkoutProgressService.instance.ensureProgressData();
    } catch (_) {
      // Progress can be refreshed manually from the page.
    }
  }

  Future<void> _refreshProgress() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await WorkoutProgressService.instance.recomputeProgress();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Не удалось обновить прогресс. Попробуйте ещё раз.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _startNewTraining() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_training');

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CurrentWorkoutScreen(),
      ),
    );
  }

  void _openExerciseDetails(ExerciseProgressSummary summary) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseProgressDetailPage(summary: summary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      body: SafeArea(
        child: StreamBuilder<WorkoutProgressOverview>(
          stream: WorkoutProgressService.instance.watchOverview(),
          builder: (context, overviewSnapshot) {
            return StreamBuilder<List<ExerciseProgressSummary>>(
              stream: WorkoutProgressService.instance.watchExerciseSummaries(),
              builder: (context, summarySnapshot) {
                return StreamBuilder<List<ArchivedTraining>>(
                  stream: WorkoutArchiveService.instance.watchArchive(),
                  builder: (context, archiveSnapshot) {
                    final overview = overviewSnapshot.data ??
                        const WorkoutProgressOverview.empty();
                    final summaries =
                        summarySnapshot.data ?? const <ExerciseProgressSummary>[];
                    final archivedTrainings =
                        archiveSnapshot.data ?? const <ArchivedTraining>[];

                    if (overviewSnapshot.connectionState ==
                            ConnectionState.waiting &&
                        summarySnapshot.connectionState ==
                            ConnectionState.waiting &&
                        archiveSnapshot.connectionState ==
                            ConnectionState.waiting &&
                        summaries.isEmpty &&
                        archivedTrainings.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (summarySnapshot.hasError || archiveSnapshot.hasError) {
                      return _buildErrorState();
                    }

                    return RefreshIndicator(
                      onRefresh: _refreshProgress,
                      color: elevatedButtonBackgroundColor,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeader(),
                                  const SizedBox(height: 18),
                                  if (summaries.isEmpty)
                                    _buildEmptyState()
                                  else ...[
                                    _buildOverviewCard(overview),
                                    const SizedBox(height: 18),
                                    _buildActivityCard(archivedTrainings),
                                    const SizedBox(height: 18),
                                    _buildExerciseSectionTitle(summaries.length),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          if (summaries.isNotEmpty)
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => Padding(
                                    padding: EdgeInsets.only(
                                      bottom: index == summaries.length - 1
                                          ? 0
                                          : 14,
                                    ),
                                    child: _buildExerciseCard(summaries[index]),
                                  ),
                                  childCount: summaries.length,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Прогресс',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Здесь собраны личные рекорды, динамика и история по упражнениям.',
                style: TextStyle(
                  fontSize: 15,
                  color: _textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _isRefreshing ? null : _refreshProgress,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _borderSoft),
            ),
            child: _isRefreshing
                ? Padding(
                    padding: const EdgeInsets.all(14),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: elevatedButtonBackgroundColor,
                    ),
                  )
                : const Icon(
                    Icons.refresh_rounded,
                    color: _textPrimary,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(WorkoutProgressOverview overview) {
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
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: elevatedButtonBackgroundColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.show_chart_rounded,
                  color: elevatedButtonBackgroundColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Общая картина',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${overview.totalTrainings} тренировок сохранено',
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStatTile(
                title: 'Упражнения',
                value: '${overview.uniqueExercises}',
                subtitle: 'уникальных',
              ),
              _buildStatTile(
                title: 'Подходы',
                value: '${overview.totalApproaches}',
                subtitle: 'всего в архиве',
              ),
              _buildStatTile(
                title: 'Объём',
                value: _formatWeight(overview.totalVolumeKg),
                subtitle: 'накопленный',
              ),
              _buildStatTile(
                title: 'Последняя',
                value: _formatDate(overview.lastCompletedAt),
                subtitle: 'тренировка',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _softTileColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(List<ArchivedTraining> archivedTrainings) {
    final bars = _buildWeekBars(archivedTrainings);
    final maxCount = bars.fold<int>(0, (max, entry) {
      return entry.count > max ? entry.count : max;
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Активность за 7 дней',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Чем чаще тренировки попадают в архив, тем быстрее наполняется история прогресса.',
            style: const TextStyle(
              fontSize: 14,
              color: _textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: bars.map((bar) {
                final ratio = maxCount == 0 ? 0.08 : bar.count / maxCount;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${bar.count}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: 24 + (88 * ratio),
                          decoration: BoxDecoration(
                            color: bar.count == 0
                                ? _softTileColor
                                : elevatedButtonBackgroundColor,
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          bar.label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseSectionTitle(int count) {
    return Text(
      'Упражнения в прогрессе: $count',
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: _textPrimary,
      ),
    );
  }

  Widget _buildExerciseCard(ExerciseProgressSummary summary) {
    return GestureDetector(
      onTap: () => _openExerciseDetails(summary),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _borderSoft),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 8),
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
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: elevatedButtonBackgroundColor.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _exerciseIcon(summary.trackingType),
                    color: elevatedButtonBackgroundColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.exerciseName,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: _textPrimary,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _exerciseSubtitle(summary),
                        style: const TextStyle(
                          fontSize: 14,
                          color: _textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: _textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildInfoChip(
                  icon: Icons.emoji_events_outlined,
                  text: _bestResultLabel(summary),
                ),
                _buildInfoChip(
                  icon: Icons.trending_up_rounded,
                  text: _trendLabel(summary),
                ),
                _buildInfoChip(
                  icon: Icons.history_rounded,
                  text: '${summary.sessionCount} сессий',
                ),
              ],
            ),
          ],
        ),
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
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
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: _softTileColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.show_chart_rounded,
              size: 42,
              color: elevatedButtonBackgroundColor,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Прогресс пока пуст',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Завершите хотя бы одну тренировку и сохраните её в архив. После этого появятся графики, рекорды и история по упражнениям.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: _textSecondary,
              height: 1.35,
            ),
          ),
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
              child: const Text(
                'Начать тренировку',
                style: TextStyle(
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

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _borderSoft),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: _textSecondary,
              ),
              SizedBox(height: 14),
              Text(
                'Не удалось загрузить прогресс',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Проверьте подключение к интернету и попробуйте обновить данные ещё раз.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: _textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                isActive: false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainPage()),
                  );
                },
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
                isActive: true,
                onTap: null,
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
              fontSize: 12,
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

  List<_WeekBarData> _buildWeekBars(List<ArchivedTraining> archivedTrainings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dates = List<DateTime>.generate(
      7,
      (index) => today.subtract(Duration(days: 6 - index)),
    );
    final counts = <DateTime, int>{
      for (final date in dates) date: 0,
    };

    for (final training in archivedTrainings) {
      final completedAt = training.completedAt?.toLocal();
      if (completedAt == null) continue;
      final day = DateTime(completedAt.year, completedAt.month, completedAt.day);
      if (counts.containsKey(day)) {
        counts[day] = (counts[day] ?? 0) + 1;
      }
    }

    const labels = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

    return dates.map((date) {
      return _WeekBarData(
        label: labels[date.weekday - 1],
        count: counts[date] ?? 0,
      );
    }).toList();
  }

  String _exerciseSubtitle(ExerciseProgressSummary summary) {
    switch (summary.trackingType) {
      case ExerciseTrackingType.weightReps:
        return 'Оценивает прогресс по силовому результату, рабочему весу и объёму.';
      case ExerciseTrackingType.bodyweightReps:
        return 'Считает рост по общей нагрузке, дополнительному весу и повторениям.';
      case ExerciseTrackingType.duration:
        return 'Отслеживает лучший и суммарный результат по времени.';
    }
  }

  String _bestResultLabel(ExerciseProgressSummary summary) {
    switch (summary.trackingType) {
      case ExerciseTrackingType.weightReps:
        return 'Пик ${_formatWeight(summary.personalBestValue)} 1ПМ';
      case ExerciseTrackingType.bodyweightReps:
        return 'Пик ${_formatWeight(summary.personalBestValue)} нагрузки';
      case ExerciseTrackingType.duration:
        return 'Пик ${_formatDuration(summary.bestDurationSeconds ?? 0)}';
    }
  }

  String _trendLabel(ExerciseProgressSummary summary) {
    final value = summary.improvementValue;
    if (value.abs() < 0.001) {
      return 'Стабильно';
    }

    final sign = value > 0 ? '+' : '';
    switch (summary.trackingType) {
      case ExerciseTrackingType.weightReps:
        return '$sign${_formatWeight(value)} к старту';
      case ExerciseTrackingType.bodyweightReps:
        return '$sign${_formatWeight(value)} к старту';
      case ExerciseTrackingType.duration:
        return '$sign${_formatDuration(value.round())} к старту';
    }
  }

  IconData _exerciseIcon(ExerciseTrackingType trackingType) {
    switch (trackingType) {
      case ExerciseTrackingType.weightReps:
        return Icons.fitness_center_rounded;
      case ExerciseTrackingType.bodyweightReps:
        return Icons.accessibility_new_rounded;
      case ExerciseTrackingType.duration:
        return Icons.timer_outlined;
    }
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'Нет данных';
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    return '$day.$month.$year';
  }

  String _formatWeight(double value) {
    if (value == value.roundToDouble()) {
      return '${value.toStringAsFixed(0)} кг';
    }
    return '${value.toStringAsFixed(1)} кг';
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = remainder.toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}

class _WeekBarData {
  const _WeekBarData({
    required this.label,
    required this.count,
  });

  final String label;
  final int count;
}
