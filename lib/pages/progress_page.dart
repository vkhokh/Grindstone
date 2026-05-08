import 'package:dp/colors.dart';
import 'package:dp/models/archived_training.dart';
import 'package:dp/models/exercise_catalog_item.dart';
import 'package:dp/models/exercise_catalog_data.dart';
import 'package:dp/models/workout_progress.dart';
import 'package:dp/pages/current_training_page.dart';
import 'package:dp/pages/exercise_progress_detail_page.dart';
import 'package:dp/pages/main_page.dart';
import 'package:dp/pages/profile_page.dart';
import 'package:dp/pages/training_archive_page.dart';
import 'package:dp/services/custom_exercise_service.dart';
import 'package:dp/services/workout_archive_service.dart';
import 'package:dp/services/workout_progress_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _ExerciseProgressFilter {
  all,
  improved,
  stable,
  declined,
}

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  static const String _allMuscleGroups = 'Все';

  bool _isRefreshing = false;
  _ExerciseProgressFilter _selectedFilter = _ExerciseProgressFilter.all;
  String _selectedMuscleGroup = _allMuscleGroups;
  Map<String, String> _exerciseMuscleGroups = {};

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
    _loadExerciseMuscleGroups();
  }

  Future<void> _loadExerciseMuscleGroups() async {
    final customExercises = await CustomExerciseService.instance.loadExercises();

    final allExercises = [
      ...exerciseCatalog,
      ...customExercises,
    ];

    final groups = <String, String>{};

    for (final exercise in allExercises) {
      groups[exercise.id] = exercise.muscleGroup;
      groups[exercise.name.trim().toLowerCase()] = exercise.muscleGroup;
    }

    if (!mounted) return;

    setState(() {
      _exerciseMuscleGroups = groups;
    });
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
          content: Text('Не удалось обновить прогресс. Попробуйте ещё раз.'),
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
      MaterialPageRoute(builder: (context) => const CurrentWorkoutScreen()),
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
                    final overview =
                        overviewSnapshot.data ??
                        const WorkoutProgressOverview.empty();
                    final summaries =
                        summarySnapshot.data ??
                        const <ExerciseProgressSummary>[];
                        final progressFilteredSummaries =
    _filterSummariesByProgress(summaries);
                    final archivedTrainings =
                        archiveSnapshot.data ?? const <ArchivedTraining>[];
                    final filteredSummaries = _filterSummaries(summaries);

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
                                    _buildHeroInsightCard(overview, summaries),
                                    const SizedBox(height: 14),
                                    _buildAchievementsCard(
                                      overview,
                                      summaries,
                                      archivedTrainings,
                                    ),
                                    const SizedBox(height: 18),
                                    _buildBestResultsSection(summaries),
                                    const SizedBox(height: 18),
                                    _buildActivityCard(archivedTrainings),
                                    const SizedBox(height: 18),
                                    _buildExerciseSectionTitle(
                                      summaries.length,
                                      filteredSummaries.length,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildExerciseFilters(summaries),
                                    const SizedBox(height: 10),
                                    _buildMuscleGroupFilters(progressFilteredSummaries),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          if (summaries.isNotEmpty && filteredSummaries.isEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                                child: _buildEmptyFilterState(),
                              ),
                            ),
                          if (filteredSummaries.isNotEmpty)
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                0,
                                20,
                                120,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => Padding(
                                    padding: EdgeInsets.only(
                                      bottom: index == filteredSummaries.length - 1
                                          ? 0
                                          : 14,
                                    ),
                                    child: _buildExerciseCard(filteredSummaries[index]),
                                  ),
                                  childCount: filteredSummaries.length,
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
                : const Icon(Icons.refresh_rounded, color: _textPrimary),
          ),
        ),
      ],
    );
  }


  Widget _buildHeroInsightCard(
    WorkoutProgressOverview overview,
    List<ExerciseProgressSummary> summaries,
  ) {
    final bestImproved = _bestImprovedExercise(summaries);

    final title = bestImproved == null ? 'Прогресс собирается' : 'Лучший рост';

    final mainText = bestImproved == null
        ? '${overview.totalTrainings} ${_pluralTrainings(overview.totalTrainings)} в архиве'
        : bestImproved.exerciseName;

    final subtitle = bestImproved == null
        ? 'Сохрани ещё пару тренировок, чтобы увидеть динамику, сильные упражнения и личные результаты.'
        : '${_trendLabel(bestImproved)} · ${_bestResultLabel(bestImproved)}';

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: elevatedButtonBackgroundColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              bestImproved == null
                  ? Icons.insights_rounded
                  : Icons.trending_up_rounded,
              color: elevatedButtonBackgroundColor,
              size: 30,
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
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  mainText,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
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

  Widget _buildAchievementsCard(
    WorkoutProgressOverview overview,
    List<ExerciseProgressSummary> summaries,
    List<ArchivedTraining> archivedTrainings,
  ) {
    final improved = summaries
        .where((summary) => summary.improvementValue > 0.001)
        .toList();

    final bestResult = summaries.isEmpty
        ? null
        : ([...summaries]
              ..sort(
                (a, b) => b.personalBestValue.compareTo(a.personalBestValue),
              ))
            .first;

    final weeklyTrainings = _trainingsInLastDays(archivedTrainings, 7);

    final items = <_AchievementItem>[
      if (improved.isNotEmpty)
        _AchievementItem(
          icon: Icons.trending_up_rounded,
          title: 'Есть рост',
          subtitle:
              '${improved.length} ${_pluralExercises(improved.length)} стали сильнее',
        )
      else
        const _AchievementItem(
          icon: Icons.insights_rounded,
          title: 'Рост скоро появится',
          subtitle: 'Сохрани ещё пару тренировок для честной динамики',
        ),
      if (bestResult != null)
        _AchievementItem(
          icon: Icons.emoji_events_rounded,
          title: 'Лучший результат',
          subtitle:
              '${bestResult.exerciseName} · ${_bestResultLabel(bestResult)}',
        ),
      _AchievementItem(
        icon: Icons.local_fire_department_rounded,
        title: weeklyTrainings > 0 ? 'Неделя в движении' : 'Неделя пока пустая',
        subtitle: weeklyTrainings > 0
            ? '$weeklyTrainings ${_pluralTrainings(weeklyTrainings)} за последние 7 дней'
            : 'Сохрани тренировку, чтобы начать серию',
      ),
    ];

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
            'Достижения',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Главное, что изменилось в твоих тренировках.',
            style: TextStyle(
              fontSize: 14,
              color: _textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) {
            final isLast = item == items.last;

            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
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
                      item.icon,
                      color: elevatedButtonBackgroundColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
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

  Widget _buildBestResultsSection(List<ExerciseProgressSummary> summaries) {
    final visible = ([...summaries]
          ..sort(
            (a, b) => b.personalBestValue.compareTo(a.personalBestValue),
          ))
        .take(3)
        .toList();

    if (visible.isEmpty) {
      return const SizedBox.shrink();
    }

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
            'Лучшие результаты',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Твои максимальные результаты по упражнениям.',
            style: TextStyle(
              fontSize: 14,
              color: _textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          ...visible.map((summary) {
            final isLast = summary == visible.last;

            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _openExerciseDetails(summary),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: elevatedButtonBackgroundColor.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _exerciseIcon(summary.trackingType),
                        color: elevatedButtonBackgroundColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        summary.exerciseName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
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
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: _textSecondary,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
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
          Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildStatTile(
                        title:
                            '\u0423\u043f\u0440\u0430\u0436\u043d\u0435\u043d\u0438\u044f',
                        value: '${overview.uniqueExercises}',
                        subtitle:
                            '\u0443\u043d\u0438\u043a\u0430\u043b\u044c\u043d\u044b\u0445',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatTile(
                        title: '\u041f\u043e\u0434\u0445\u043e\u0434\u044b',
                        value: '${overview.totalApproaches}',
                        subtitle:
                            '\u0432\u0441\u0435\u0433\u043e \u0432 \u0430\u0440\u0445\u0438\u0432\u0435',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildStatTile(
                        title: '\u041e\u0431\u044a\u0435\u043c',
                        value: _formatWeight(overview.totalVolumeKg),
                        subtitle:
                            '\u043d\u0430\u043a\u043e\u043f\u043b\u0435\u043d\u043d\u044b\u0439',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatTile(
                        title:
                            '\u041f\u043e\u0441\u043b\u0435\u0434\u043d\u044f\u044f',
                        value: _formatDate(overview.lastCompletedAt),
                        subtitle:
                            '\u0442\u0440\u0435\u043d\u0438\u0440\u043e\u0432\u043a\u0430',
                      ),
                    ),
                  ],
                ),
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
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 108),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: _textSecondary),
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
            'Тренировки за неделю',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Показывает, в какие дни ты сохранял тренировки.',
            style: const TextStyle(
              fontSize: 14,
              color: _textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final screenHeight = MediaQuery.sizeOf(context).height;
              final chartHeight = screenHeight < 700 ? 132.0 : 156.0;
              final labelAreaHeight = 22.0;
              final valueAreaHeight = 20.0;
              final verticalGaps = 18.0;
              final availableBarHeight =
                  chartHeight - labelAreaHeight - valueAreaHeight - verticalGaps;
              final maxBarHeight =
                  availableBarHeight.clamp(48.0, 96.0).toDouble();
              final minBarHeight = maxBarHeight * 0.16;

              return SizedBox(
                height: chartHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: bars.map((bar) {
                    final ratio = maxCount == 0 ? 0.0 : bar.count / maxCount;
                    final barHeight = bar.count == 0
                        ? minBarHeight
                        : minBarHeight + ((maxBarHeight - minBarHeight) * ratio);

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: valueAreaHeight,
                              child: Center(
                                child: Text(
                                  '${bar.count}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: bar.count == 0
                                    ? _softTileColor
                                    : elevatedButtonBackgroundColor,
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: labelAreaHeight,
                              child: Center(
                                child: Text(
                                  bar.label,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseSectionTitle(
  int totalCount,
  int filteredCount,
) {
  final hasActiveFilters = _selectedFilter != _ExerciseProgressFilter.all ||
      _selectedMuscleGroup != _allMuscleGroups;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'История упражнений',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: _textPrimary,
        ),
      ),
      if (hasActiveFilters) ...[
        const SizedBox(height: 4),
        Text(
          'Показано $filteredCount из $totalCount',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
          ),
        ),
      ],
    ],
  );
}

  Widget _buildExerciseFilters(List<ExerciseProgressSummary> summaries) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterChip(
            filter: _ExerciseProgressFilter.all,
            label: 'Все',
            count: summaries.length,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            filter: _ExerciseProgressFilter.improved,
            label: 'С ростом',
            count: summaries
                .where((summary) => summary.improvementValue > 0.001)
                .length,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            filter: _ExerciseProgressFilter.stable,
            label: 'Без изменений',
            count: summaries
                .where(
                  (summary) =>
                      summary.improvementValue >= -0.001 &&
                      summary.improvementValue <= 0.001,
                )
                .length,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            filter: _ExerciseProgressFilter.declined,
            label: 'Просадка',
            count: summaries
                .where((summary) => summary.improvementValue < -0.001)
                .length,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required _ExerciseProgressFilter filter,
    required String label,
    required int count,
  }) {
    final isSelected = _selectedFilter == filter;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? elevatedButtonBackgroundColor : _cardColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? elevatedButtonBackgroundColor : _borderSoft,
          ),
        ),
        child: Text(
          '$label $count',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : _textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildMuscleGroupFilters(List<ExerciseProgressSummary> summaries) {
    final groups = _availableMuscleGroups(summaries);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: groups.map((group) {
          final isSelected = group == _selectedMuscleGroup;
          final count = group == _allMuscleGroups
              ? summaries.length
              : summaries
                  .where((summary) => _muscleGroupForSummary(summary) == group)
                  .length;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMuscleGroup = group;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? elevatedButtonBackgroundColor : _cardColor,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected
                        ? elevatedButtonBackgroundColor
                        : _borderSoft,
                  ),
                ),
                child: Text(
                  '$group $count',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : _textPrimary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
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
                const Icon(Icons.chevron_right_rounded, color: _textSecondary),
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

  Widget _buildInfoChip({required IconData icon, required String text}) {
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

  Widget _buildEmptyFilterState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _borderSoft),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Здесь пока пусто',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Попробуй выбрать другой фильтр или сохранить больше тренировок.',
            style: TextStyle(
              fontSize: 14,
              color: _textSecondary,
              height: 1.35,
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
            style: TextStyle(fontSize: 15, color: _textSecondary, height: 1.35),
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
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
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
              Icon(Icons.cloud_off_rounded, size: 40, color: _textSecondary),
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
    final color = isActive
        ? elevatedButtonBackgroundColor
        : const Color(0xFF6F6F74);

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
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
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

  int _trainingsInLastDays(
    List<ArchivedTraining> trainings,
    int days,
  ) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));

    return trainings.where((training) {
      final completedAt = training.completedAt?.toLocal();
      if (completedAt == null) return false;

      final day = DateTime(
        completedAt.year,
        completedAt.month,
        completedAt.day,
      );

      return !day.isBefore(start);
    }).length;
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

  String _pluralTrainings(int count) {
    final mod10 = count % 10;
    final mod100 = count % 100;

    if (mod10 == 1 && mod100 != 11) return 'тренировка';

    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return 'тренировки';
    }

    return 'тренировок';
  }
List<ExerciseProgressSummary> _filterSummariesByProgress(
  List<ExerciseProgressSummary> summaries,
) {
  switch (_selectedFilter) {
    case _ExerciseProgressFilter.all:
      return summaries;

    case _ExerciseProgressFilter.improved:
      return summaries
          .where((summary) => summary.improvementValue > 0.001)
          .toList();

    case _ExerciseProgressFilter.stable:
      return summaries
          .where(
            (summary) =>
                summary.improvementValue >= -0.001 &&
                summary.improvementValue <= 0.001,
          )
          .toList();

    case _ExerciseProgressFilter.declined:
      return summaries
          .where((summary) => summary.improvementValue < -0.001)
          .toList();
  }
}
 List<ExerciseProgressSummary> _filterSummaries(
  List<ExerciseProgressSummary> summaries,
) {
  final progressFiltered = _filterSummariesByProgress(summaries);

  if (_selectedMuscleGroup == _allMuscleGroups) {
    return progressFiltered;
  }

  return progressFiltered
      .where(
        (summary) =>
            _muscleGroupForSummary(summary) == _selectedMuscleGroup,
      )
      .toList();
}

  String _muscleGroupForSummary(ExerciseProgressSummary summary) {
    final id = summary.exerciseId;
    if (id != null && _exerciseMuscleGroups.containsKey(id)) {
      return _exerciseMuscleGroups[id]!;
    }

    final nameKey = summary.exerciseName.trim().toLowerCase();
    return _exerciseMuscleGroups[nameKey] ?? 'Другое';
  }

  List<String> _availableMuscleGroups(
    List<ExerciseProgressSummary> summaries,
  ) {
    final groups = summaries
        .map(_muscleGroupForSummary)
        .where((group) => group.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return [_allMuscleGroups, ...groups];
  }

  List<_WeekBarData> _buildWeekBars(List<ArchivedTraining> archivedTrainings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dates = List<DateTime>.generate(
      7,
      (index) => today.subtract(Duration(days: 6 - index)),
    );
    final counts = <DateTime, int>{for (final date in dates) date: 0};

    for (final training in archivedTrainings) {
      final completedAt = training.completedAt?.toLocal();
      if (completedAt == null) continue;
      final day = DateTime(
        completedAt.year,
        completedAt.month,
        completedAt.day,
      );
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
    if (summary.sessionCount <= 1) {
      return 'Пока одна тренировка. Динамика появится после следующих занятий.';
    }

    if (summary.improvementValue > 0.001) {
      return 'Есть рост относительно первого результата.';
    }

    if (summary.improvementValue < -0.001) {
      return 'Последний результат ниже стартового. Возможно, была лёгкая тренировка.';
    }

    return 'Результат держится примерно на одном уровне.';
  }

  String _bestResultLabel(ExerciseProgressSummary summary) {
    switch (summary.trackingType) {
      case ExerciseTrackingType.weightReps:
      case ExerciseTrackingType.bodyweightReps:
        return 'Лучший результат ${_formatWeight(summary.personalBestValue)}';
      case ExerciseTrackingType.duration:
        return 'Лучшее время ${_formatDuration(summary.bestDurationSeconds ?? 0)}';
    }
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

  String _trendLabel(ExerciseProgressSummary summary) {
    final value = summary.improvementValue;

    if (value.abs() < 0.001) {
      return 'Без заметных изменений';
    }

    final sign = value > 0 ? '+' : '';

    switch (summary.trackingType) {
      case ExerciseTrackingType.weightReps:
      case ExerciseTrackingType.bodyweightReps:
        return '$sign${_formatWeight(value)} с первой тренировки';
      case ExerciseTrackingType.duration:
        return '$sign${_formatDuration(value.round())} с первой тренировки';
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
    final absValue = value.abs();
    final sign = value < 0 ? '-' : '';

    if (absValue == absValue.roundToDouble()) {
      return '$sign${absValue.toInt()} кг';
    }

    return '$sign${absValue.toStringAsFixed(1).replaceAll('.', ',')} кг';
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
  const _WeekBarData({required this.label, required this.count});

  final String label;
  final int count;
}

class _AchievementItem {
  const _AchievementItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}
