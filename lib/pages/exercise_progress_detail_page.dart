import 'package:dp/colors.dart';
import 'package:dp/models/exercise_catalog_item.dart';
import 'package:dp/models/workout_progress.dart';
import 'package:dp/services/workout_progress_service.dart';
import 'package:dp/widgets/progress_line_chart.dart';
import 'package:flutter/material.dart';

class ExerciseProgressDetailPage extends StatefulWidget {
  const ExerciseProgressDetailPage({
    super.key,
    required this.summary,
  });

  final ExerciseProgressSummary summary;

  @override
  State<ExerciseProgressDetailPage> createState() =>
      _ExerciseProgressDetailPageState();
}

class _ExerciseProgressDetailPageState extends State<ExerciseProgressDetailPage> {
  late _DetailMetric _selectedMetric;

  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _cardColor = Color(0xFFFFFBF5);
  static const Color _softTileColor = Color(0xFFFCF7EF);
  static const Color _borderSoft = Color(0xFFE8E2D6);

  @override
  void initState() {
    super.initState();
    _selectedMetric = _metricOptions(widget.summary.trackingType).first;
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;

    return Scaffold(
      backgroundColor: backGroundColor,
      body: SafeArea(
        child: StreamBuilder<List<ExerciseProgressPoint>>(
          stream: WorkoutProgressService.instance
              .watchExercisePoints(summary.exerciseKey),
          builder: (context, snapshot) {
            final points = snapshot.data ?? const <ExerciseProgressPoint>[];

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 18),
                        _buildHero(summary),
                        const SizedBox(height: 18),
                        _buildMetricsPicker(summary.trackingType),
                        const SizedBox(height: 18),
                        _buildChartCard(summary, points),
                        const SizedBox(height: 18),
                        _buildInsightRow(summary),
                        const SizedBox(height: 18),
                        _buildRecentTitle(),
                      ],
                    ),
                  ),
                ),
                if (snapshot.connectionState == ConnectionState.waiting &&
                    points.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (points.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      child: _buildEmptyState(),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final point = points[points.length - 1 - index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == points.length - 1 ? 0 : 12,
                            ),
                            child: _buildSessionCard(summary, point),
                          );
                        },
                        childCount: points.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
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
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Детали прогресса',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'История результатов по выбранному упражнению',
                style: TextStyle(
                  fontSize: 14,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHero(ExerciseProgressSummary summary) {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: elevatedButtonBackgroundColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              _trackingTypeLabel(summary.trackingType),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            summary.exerciseName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _heroSubtitle(summary),
            style: const TextStyle(
              fontSize: 15,
              color: _textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildInfoChip(
                icon: Icons.emoji_events_outlined,
                text: _personalBestLabel(summary),
              ),
              _buildInfoChip(
                icon: Icons.trending_up_rounded,
                text: _improvementLabel(summary),
              ),
              _buildInfoChip(
                icon: Icons.history_rounded,
                text: '${summary.sessionCount} сессий',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsPicker(ExerciseTrackingType trackingType) {
    final options = _metricOptions(trackingType);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((metric) {
          final isSelected = metric == _selectedMetric;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(metric.label),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedMetric = metric;
                });
              },
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                color: isSelected ? _textPrimary : _textSecondary,
              ),
              selectedColor: elevatedButtonBackgroundColor.withOpacity(0.2),
              backgroundColor: _cardColor,
              side: BorderSide(color: _borderSoft),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartCard(
    ExerciseProgressSummary summary,
    List<ExerciseProgressPoint> points,
  ) {
    final chartPoints = points
        .map(
          (point) => ProgressChartPoint(
            label: _shortDate(point.completedAt),
            value: _metricValue(point, _selectedMetric),
          ),
        )
        .toList();

    final latestValue =
        points.isEmpty ? null : _metricValue(points.last, _selectedMetric);

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
          Text(
            _selectedMetric.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            latestValue == null
                ? 'Нет данных'
                : _formatMetricNumber(summary.trackingType, _selectedMetric, latestValue),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            points.isEmpty
                ? 'График появится после сохранённых тренировок.'
                : 'Каждая точка показывает результат одной завершённой тренировки.',
            style: const TextStyle(
              fontSize: 14,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          ProgressLineChart(points: chartPoints),
        ],
      ),
    );
  }

  Widget _buildInsightRow(ExerciseProgressSummary summary) {
    return Row(
      children: [
        Expanded(
          child: _buildInsightCard(
            title: 'Подходы',
            value: '${summary.approachCount}',
            subtitle: 'Всего сохранено',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInsightCard(
            title: 'Последний раз',
            value: _longDate(summary.lastCompletedAt),
            subtitle: 'Дата выполнения',
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTitle() {
    return const Text(
      'Последние тренировки',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: _textPrimary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _borderSoft),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _softTileColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.show_chart_rounded,
              size: 34,
              color: elevatedButtonBackgroundColor,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'История пока не сформировалась',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'После нескольких завершённых тренировок здесь появятся точки графика и подробная динамика.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: _textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(
    ExerciseProgressSummary summary,
    ExerciseProgressPoint point,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  point.trainingName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
              ),
              Text(
                _longDate(point.completedAt),
                style: const TextStyle(
                  fontSize: 13,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _sessionMetrics(summary.trackingType, point)
                .map(
                  (metric) => _buildInfoChip(
                    icon: metric.icon,
                    text: metric.text,
                  ),
                )
                .toList(),
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

  String _heroSubtitle(ExerciseProgressSummary summary) {
    switch (summary.trackingType) {
      case ExerciseTrackingType.weightReps:
        return 'Прогресс считается по оценочному силовому результату, рабочему весу, повторениям и объёму.';
      case ExerciseTrackingType.bodyweightReps:
        return 'Для упражнений с собственным весом отслеживаются общий вес нагрузки, дополнительный вес и повторения.';
      case ExerciseTrackingType.duration:
        return 'Для упражнений на время отображается лучший и суммарный результат по каждой тренировке.';
    }
  }

  String _trackingTypeLabel(ExerciseTrackingType trackingType) {
    switch (trackingType) {
      case ExerciseTrackingType.weightReps:
        return 'Вес и повторения';
      case ExerciseTrackingType.bodyweightReps:
        return 'Собственный вес';
      case ExerciseTrackingType.duration:
        return 'На время';
    }
  }

  String _personalBestLabel(ExerciseProgressSummary summary) {
    switch (summary.trackingType) {
      case ExerciseTrackingType.weightReps:
        return 'Пик: ${_formatDouble(summary.personalBestValue)} кг 1ПМ';
      case ExerciseTrackingType.bodyweightReps:
        return 'Пик: ${_formatDouble(summary.personalBestValue)} кг нагрузки';
      case ExerciseTrackingType.duration:
        return 'Пик: ${_formatDuration(summary.bestDurationSeconds ?? 0)}';
    }
  }

  String _improvementLabel(ExerciseProgressSummary summary) {
    if (summary.improvementValue.abs() < 0.001) {
      return 'Без изменений';
    }

    final sign = summary.improvementValue > 0 ? '+' : '';
    switch (summary.trackingType) {
      case ExerciseTrackingType.weightReps:
        return '$sign${_formatDouble(summary.improvementValue)} кг';
      case ExerciseTrackingType.bodyweightReps:
        return '$sign${_formatDouble(summary.improvementValue)} кг';
      case ExerciseTrackingType.duration:
        return '$sign${_formatDuration(summary.improvementValue.round())}';
    }
  }

  List<_DetailMetric> _metricOptions(ExerciseTrackingType trackingType) {
    switch (trackingType) {
      case ExerciseTrackingType.weightReps:
        return const [
          _DetailMetric.performance,
          _DetailMetric.weight,
          _DetailMetric.reps,
          _DetailMetric.volume,
        ];
      case ExerciseTrackingType.bodyweightReps:
        return const [
          _DetailMetric.performance,
          _DetailMetric.additionalWeight,
          _DetailMetric.reps,
          _DetailMetric.volume,
        ];
      case ExerciseTrackingType.duration:
        return const [
          _DetailMetric.performance,
          _DetailMetric.totalDuration,
        ];
    }
  }

  double _metricValue(ExerciseProgressPoint point, _DetailMetric metric) {
    switch (metric) {
      case _DetailMetric.performance:
        return point.performanceValue;
      case _DetailMetric.weight:
        return point.bestWeightKg ?? 0;
      case _DetailMetric.reps:
        return (point.bestReps ?? 0).toDouble();
      case _DetailMetric.volume:
        return point.totalVolumeKg;
      case _DetailMetric.additionalWeight:
        return point.bestAdditionalWeightKg ?? 0;
      case _DetailMetric.totalDuration:
        return point.totalDurationSeconds.toDouble();
    }
  }

  String _formatMetricNumber(
    ExerciseTrackingType trackingType,
    _DetailMetric metric,
    double value,
  ) {
    switch (metric) {
      case _DetailMetric.performance:
        if (trackingType == ExerciseTrackingType.duration) {
          return _formatDuration(value.round());
        }
        return '${_formatDouble(value)} кг';
      case _DetailMetric.weight:
        return '${_formatDouble(value)} кг';
      case _DetailMetric.reps:
        return '${value.round()} повт.';
      case _DetailMetric.volume:
        return '${_formatDouble(value)} кг';
      case _DetailMetric.additionalWeight:
        return '${_formatDouble(value)} кг';
      case _DetailMetric.totalDuration:
        return _formatDuration(value.round());
    }
  }

  List<_SessionMetricChip> _sessionMetrics(
    ExerciseTrackingType trackingType,
    ExerciseProgressPoint point,
  ) {
    switch (trackingType) {
      case ExerciseTrackingType.weightReps:
        return [
          _SessionMetricChip(
            icon: Icons.fitness_center_rounded,
            text: '${_formatDouble(point.bestWeightKg ?? 0)} кг',
          ),
          _SessionMetricChip(
            icon: Icons.repeat_rounded,
            text: '${point.bestReps ?? 0} повт.',
          ),
          _SessionMetricChip(
            icon: Icons.local_fire_department_rounded,
            text: '${_formatDouble(point.totalVolumeKg)} кг объёма',
          ),
        ];
      case ExerciseTrackingType.bodyweightReps:
        return [
          _SessionMetricChip(
            icon: Icons.add_circle_outline_rounded,
            text: '${_formatDouble(point.bestAdditionalWeightKg ?? 0)} кг доп.',
          ),
          _SessionMetricChip(
            icon: Icons.repeat_rounded,
            text: '${point.bestReps ?? 0} повт.',
          ),
          _SessionMetricChip(
            icon: Icons.monitor_weight_outlined,
            text: '${_formatDouble(point.bestTotalLoadKg ?? 0)} кг нагрузка',
          ),
        ];
      case ExerciseTrackingType.duration:
        return [
          _SessionMetricChip(
            icon: Icons.timer_outlined,
            text: _formatDuration(point.bestDurationSeconds ?? 0),
          ),
          _SessionMetricChip(
            icon: Icons.timelapse_rounded,
            text: '${_formatDuration(point.totalDurationSeconds)} суммарно',
          ),
          _SessionMetricChip(
            icon: Icons.layers_outlined,
            text: '${point.approachCount} подходов',
          ),
        ];
    }
  }

  String _shortDate(DateTime? value) {
    if (value == null) return '--';
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day.$month';
  }

  String _longDate(DateTime? value) {
    if (value == null) return 'Недавно';
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    return '$day.$month.$year';
  }

  String _formatDouble(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = remainder.toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}

enum _DetailMetric {
  performance('Прогресс'),
  weight('Вес'),
  reps('Повторы'),
  volume('Объём'),
  additionalWeight('Доп. вес'),
  totalDuration('Общее время');

  const _DetailMetric(this.label);

  final String label;
}

class _SessionMetricChip {
  const _SessionMetricChip({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;
}
