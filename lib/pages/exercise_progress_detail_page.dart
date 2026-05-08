import 'dart:math' as math;

import 'package:dp/colors.dart';
import 'package:dp/models/exercise_catalog_item.dart';
import 'package:dp/models/workout_progress.dart';
import 'package:dp/services/workout_progress_service.dart';
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
String _chartMetricTitle(_DetailMetric metric) {
  switch (metric) {
    case _DetailMetric.weight:
      return 'Последний вес';

    case _DetailMetric.reps:
      return 'Последние повторения';

    case _DetailMetric.additionalWeight:
      return 'Последний доп. вес';

    case _DetailMetric.totalDuration:
      return 'Последнее время';

    case _DetailMetric.performance:
      return 'Последний результат';

    case _DetailMetric.volume:
      return 'Последний объём';
  }
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
            tooltipTitle: _longDate(point.completedAt),
            tooltipLines: _chartTooltipLines(summary, point),
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
  _chartMetricTitle(_selectedMetric),
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
                : _formatMetricNumber(
                    summary.trackingType,
                    _selectedMetric,
                    latestValue,
                  ),
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
                : _chartDescription(_selectedMetric),
            style: const TextStyle(
              fontSize: 14,
              color: _textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          ProgressLineChart(
            points: chartPoints,
            valueFormatter: (value) => _formatMetricNumber(
              summary.trackingType,
              _selectedMetric,
              value,
            ),
          ),
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
        return 'Здесь видно, как менялись рабочий вес и повторения в этом упражнении.';
      case ExerciseTrackingType.bodyweightReps:
        return 'Здесь видно, как менялись дополнительный вес и повторения.';
      case ExerciseTrackingType.duration:
        return 'Здесь видно, как менялось время выполнения упражнения.';
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
        return 'Лучший результат: ${_formatWeight(summary.personalBestValue)}';
      case ExerciseTrackingType.bodyweightReps:
        return 'Лучший результат: ${_formatWeight(summary.personalBestValue)}';
      case ExerciseTrackingType.duration:
        return 'Лучшее время: ${_formatDuration(summary.bestDurationSeconds ?? 0)}';
    }
  }

  String _improvementLabel(ExerciseProgressSummary summary) {
    if (summary.improvementValue.abs() < 0.001) {
      return 'Без изменений';
    }

    final sign = summary.improvementValue > 0 ? '+' : '';
    switch (summary.trackingType) {
      case ExerciseTrackingType.weightReps:
      case ExerciseTrackingType.bodyweightReps:
        return '$sign${_formatWeight(summary.improvementValue)}';
      case ExerciseTrackingType.duration:
        return '$sign${_formatDuration(summary.improvementValue.round())}';
    }
  }

  List<_DetailMetric> _metricOptions(ExerciseTrackingType trackingType) {
    switch (trackingType) {
      case ExerciseTrackingType.weightReps:
        return const [
          _DetailMetric.weight,
          _DetailMetric.reps,
        ];
      case ExerciseTrackingType.bodyweightReps:
        return const [
          _DetailMetric.additionalWeight,
          _DetailMetric.reps,
        ];
      case ExerciseTrackingType.duration:
        return const [
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

  String _chartDescription(_DetailMetric metric) {
    switch (metric) {
      case _DetailMetric.weight:
        return 'Каждая точка показывает лучший рабочий вес в одной тренировке.';
      case _DetailMetric.reps:
        return 'Каждая точка показывает максимум повторений в одном подходе.';
      case _DetailMetric.additionalWeight:
        return 'Каждая точка показывает лучший дополнительный вес в одной тренировке.';
      case _DetailMetric.totalDuration:
        return 'Каждая точка показывает лучшее время в одной тренировке.';
      case _DetailMetric.performance:
        return 'Каждая точка показывает общий показатель результата.';
      case _DetailMetric.volume:
        return 'Каждая точка показывает суммарный объём за тренировку.';
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
        return _formatWeight(value);
      case _DetailMetric.weight:
        return _formatWeight(value);
      case _DetailMetric.reps:
        return '${value.round()} повт.';
      case _DetailMetric.volume:
        return _formatWeight(value);
      case _DetailMetric.additionalWeight:
        return _formatWeight(value);
      case _DetailMetric.totalDuration:
        return _formatDuration(value.round());
    }
  }

  List<String> _chartTooltipLines(
    ExerciseProgressSummary summary,
    ExerciseProgressPoint point,
  ) {
    switch (summary.trackingType) {
      case ExerciseTrackingType.weightReps:
        return [
          'Вес: ${_formatWeight(point.bestWeightKg ?? 0)}',
          'Повторы: ${point.bestReps ?? 0}',
          'Подходы: ${point.approachCount}',
        ];

      case ExerciseTrackingType.bodyweightReps:
        return [
          'Доп. вес: ${_formatWeight(point.bestAdditionalWeightKg ?? 0)}',
          'Повторы: ${point.bestReps ?? 0}',
          'Подходы: ${point.approachCount}',
        ];

      case ExerciseTrackingType.duration:
        return [
          'Время: ${_formatDuration(point.bestDurationSeconds ?? 0)}',
          'Подходы: ${point.approachCount}',
        ];
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
            text: _formatWeight(point.bestWeightKg ?? 0),
          ),
          _SessionMetricChip(
            icon: Icons.repeat_rounded,
            text: '${point.bestReps ?? 0} повт.',
          ),
        ];
      case ExerciseTrackingType.bodyweightReps:
        return [
          _SessionMetricChip(
            icon: Icons.add_circle_outline_rounded,
            text: '${_formatWeight(point.bestAdditionalWeightKg ?? 0)} доп.',
          ),
          _SessionMetricChip(
            icon: Icons.repeat_rounded,
            text: '${point.bestReps ?? 0} повт.',
          ),
          _SessionMetricChip(
            icon: Icons.monitor_weight_outlined,
            text: '${_formatWeight(point.bestTotalLoadKg ?? 0)} нагрузка',
          ),
        ];
      case ExerciseTrackingType.duration:
        return [
          _SessionMetricChip(
            icon: Icons.timer_outlined,
            text: _formatDuration(point.bestDurationSeconds ?? 0),
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

  String _formatWeight(double value) {
    if (value == value.roundToDouble()) {
      return '${value.toInt()} кг';
    }

    return '${value.toStringAsFixed(1).replaceAll('.', ',')} кг';
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
  totalDuration('Время');

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

class ProgressChartPoint {
  const ProgressChartPoint({
    required this.label,
    required this.value,
    required this.tooltipTitle,
    required this.tooltipLines,
  });

  final String label;
  final double value;
  final String tooltipTitle;
  final List<String> tooltipLines;
}

class ProgressLineChart extends StatefulWidget {
  const ProgressLineChart({
    super.key,
    required this.points,
    this.lineColor = const Color(0xFFF0A91C),
    this.emptyLabel = 'Недостаточно данных для графика',
    this.valueFormatter,
  });

  final List<ProgressChartPoint> points;
  final Color lineColor;
  final String emptyLabel;
  final String Function(double value)? valueFormatter;

  @override
  State<ProgressLineChart> createState() => _ProgressLineChartState();
}

class _ProgressLineChartState extends State<ProgressLineChart> {
  int? _selectedIndex;

  static const EdgeInsets _chartPadding = EdgeInsets.fromLTRB(8, 16, 8, 20);

  @override
  void didUpdateWidget(covariant ProgressLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.points != widget.points) {
      _selectedIndex = null;
      return;
    }

    if (_selectedIndex != null && _selectedIndex! >= widget.points.length) {
      _selectedIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        child: Text(
          widget.emptyLabel,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF8E8E93),
          ),
        ),
      );
    }

    final values = widget.points.map((point) => point.value).toList();
    var minValue = values.reduce(math.min);
    var maxValue = values.reduce(math.max);

    if ((maxValue - minValue).abs() < 0.0001) {
      minValue -= 1;
      maxValue += 1;
    } else {
      final padding = (maxValue - minValue) * 0.15;
      minValue -= padding;
      maxValue += padding;
    }

    final formatValue = widget.valueFormatter ?? _defaultValueFormatter;

    return Column(
      children: [
        SizedBox(
          height: 190,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 58,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAxisLabel(formatValue(maxValue)),
                    _buildAxisLabel(formatValue((maxValue + minValue) / 2)),
                    _buildAxisLabel(formatValue(minValue)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final chartSize = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );

                    final chartOffsets = _calculateChartOffsets(
                      size: chartSize,
                      minValue: minValue,
                      maxValue: maxValue,
                    );

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (details) {
                        final index = _nearestPointIndex(
                          details.localPosition,
                          chartOffsets,
                        );

                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CustomPaint(
                            painter: _ProgressLineChartPainter(
                              points: widget.points,
                              lineColor: widget.lineColor,
                              minValue: minValue,
                              maxValue: maxValue,
                              selectedIndex: _selectedIndex,
                            ),
                            child: const SizedBox.expand(),
                          ),
                          if (_selectedIndex != null &&
                              _selectedIndex! < widget.points.length &&
                              _selectedIndex! < chartOffsets.length)
                            _buildTooltip(
                              point: widget.points[_selectedIndex!],
                              offset: chartOffsets[_selectedIndex!],
                              chartSize: chartSize,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const SizedBox(width: 66),
            Expanded(
              child: Text(
                widget.points.first.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8E8E93),
                ),
              ),
            ),
            if (widget.points.length > 2)
              Text(
                widget.points[widget.points.length ~/ 2].label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8E8E93),
                ),
              ),
            Expanded(
              child: Text(
                widget.points.last.label,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8E8E93),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAxisLabel(String text) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF8E8E93),
      ),
    );
  }

  Widget _buildTooltip({
    required ProgressChartPoint point,
    required Offset offset,
    required Size chartSize,
  }) {
    const tooltipWidth = 154.0;
    const tooltipHeightEstimate = 94.0;

    final left = (offset.dx - tooltipWidth / 2)
        .clamp(0.0, math.max(0.0, chartSize.width - tooltipWidth))
        .toDouble();

    final top = (offset.dy - 86)
        .clamp(0.0, math.max(0.0, chartSize.height - 72))
        .toDouble();

    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: tooltipWidth,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                point.tooltipTitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              ...point.tooltipLines.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    line,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEDEDED),
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Offset> _calculateChartOffsets({
    required Size size,
    required double minValue,
    required double maxValue,
  }) {
    final chartWidth = size.width - _chartPadding.left - _chartPadding.right;
    final chartHeight = size.height - _chartPadding.top - _chartPadding.bottom;

    if (chartWidth <= 0 || chartHeight <= 0) {
      return const [];
    }

    return List.generate(widget.points.length, (index) {
      final dx = widget.points.length == 1
          ? _chartPadding.left + chartWidth / 2
          : _chartPadding.left +
              (chartWidth / (widget.points.length - 1)) * index;

      final normalized =
          (widget.points[index].value - minValue) / (maxValue - minValue);

      final dy = _chartPadding.top +
          chartHeight -
          (normalized * chartHeight).clamp(0.0, chartHeight).toDouble();

      return Offset(dx, dy);
    });
  }

  int? _nearestPointIndex(
    Offset tapPosition,
    List<Offset> chartOffsets,
  ) {
    if (chartOffsets.isEmpty) return null;

    var nearestIndex = 0;
    var nearestDistance = double.infinity;

    for (var index = 0; index < chartOffsets.length; index++) {
      final distance = (tapPosition - chartOffsets[index]).distance;

      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestIndex = index;
      }
    }

    if (nearestDistance > 36) {
      return null;
    }

    return nearestIndex;
  }

  String _defaultValueFormatter(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }
}

class _ProgressLineChartPainter extends CustomPainter {
  _ProgressLineChartPainter({
    required this.points,
    required this.lineColor,
    required this.minValue,
    required this.maxValue,
    required this.selectedIndex,
  });

  final List<ProgressChartPoint> points;
  final Color lineColor;
  final double minValue;
  final double maxValue;
  final int? selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    const chartPadding = EdgeInsets.fromLTRB(8, 16, 8, 20);

    final chartWidth = size.width - chartPadding.left - chartPadding.right;
    final chartHeight = size.height - chartPadding.top - chartPadding.bottom;

    if (chartWidth <= 0 || chartHeight <= 0) {
      return;
    }

    final gridPaint = Paint()
      ..color = const Color(0xFFE8E2D6)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 3; i++) {
      final dy = chartPadding.top + (chartHeight / 2) * i;

      canvas.drawLine(
        Offset(chartPadding.left, dy),
        Offset(size.width - chartPadding.right, dy),
        gridPaint,
      );
    }

    final chartPoints = <Offset>[];

    for (var index = 0; index < points.length; index++) {
      final dx = points.length == 1
          ? chartPadding.left + chartWidth / 2
          : chartPadding.left + (chartWidth / (points.length - 1)) * index;

      final normalized = (points[index].value - minValue) / (maxValue - minValue);

      final dy = chartPadding.top +
          chartHeight -
          (normalized * chartHeight).clamp(0.0, chartHeight).toDouble();

      chartPoints.add(Offset(dx, dy));
    }

    final areaPath = Path()
      ..moveTo(chartPoints.first.dx, size.height - chartPadding.bottom);

    for (final point in chartPoints) {
      areaPath.lineTo(point.dx, point.dy);
    }

    areaPath.lineTo(chartPoints.last.dx, size.height - chartPadding.bottom);
    areaPath.close();

    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withOpacity(0.24),
            lineColor.withOpacity(0.03),
          ],
        ).createShader(
          Rect.fromLTWH(
            chartPadding.left,
            chartPadding.top,
            chartWidth,
            chartHeight,
          ),
        ),
    );

    final linePath = Path()
      ..moveTo(chartPoints.first.dx, chartPoints.first.dy);

    for (final point in chartPoints.skip(1)) {
      linePath.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final pointFillPaint = Paint()..color = Colors.white;

    final pointStrokePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var index = 0; index < chartPoints.length; index++) {
      final point = chartPoints[index];
      final isSelected = index == selectedIndex;
      final radius = isSelected ? 6.5 : 4.5;

      if (isSelected) {
        canvas.drawCircle(
          point,
          12,
          Paint()..color = lineColor.withOpacity(0.14),
        );
      }

      canvas.drawCircle(point, radius, pointFillPaint);
      canvas.drawCircle(point, radius, pointStrokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressLineChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.minValue != minValue ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}
