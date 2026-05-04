import 'dart:math' as math;

import 'package:flutter/material.dart';

class ProgressChartPoint {
  const ProgressChartPoint({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;
}

class ProgressLineChart extends StatelessWidget {
  const ProgressLineChart({
    super.key,
    required this.points,
    this.lineColor = const Color(0xFFF0A91C),
    this.emptyLabel = 'Недостаточно данных для графика',
  });

  final List<ProgressChartPoint> points;
  final Color lineColor;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        child: Text(
          emptyLabel,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF8E8E93),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: CustomPaint(
            painter: _ProgressLineChartPainter(
              points: points,
              lineColor: lineColor,
            ),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                points.first.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8E8E93),
                ),
              ),
            ),
            if (points.length > 2)
              Text(
                points[points.length ~/ 2].label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8E8E93),
                ),
              ),
            Expanded(
              child: Text(
                points.last.label,
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
}

class _ProgressLineChartPainter extends CustomPainter {
  _ProgressLineChartPainter({
    required this.points,
    required this.lineColor,
  });

  final List<ProgressChartPoint> points;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    const chartPadding = EdgeInsets.fromLTRB(8, 16, 8, 20);
    final chartWidth = size.width - chartPadding.left - chartPadding.right;
    final chartHeight = size.height - chartPadding.top - chartPadding.bottom;
    if (chartWidth <= 0 || chartHeight <= 0) {
      return;
    }

    final values = points.map((point) => point.value).toList();
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

    final gridPaint = Paint()
      ..color = const Color(0xFFE8E2D6)
      ..strokeWidth = 1;
    final axisPath = Path();
    for (var i = 0; i < 4; i++) {
      final dy = chartPadding.top + (chartHeight / 3) * i;
      axisPath.moveTo(chartPadding.left, dy);
      axisPath.lineTo(size.width - chartPadding.right, dy);
    }
    canvas.drawPath(
      axisPath,
      gridPaint
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final chartPoints = <Offset>[];
    for (var index = 0; index < points.length; index++) {
      final dx = points.length == 1
          ? chartPadding.left + chartWidth / 2
          : chartPadding.left + (chartWidth / (points.length - 1)) * index;
      final normalized =
          (points[index].value - minValue) / (maxValue - minValue);
      final dy = chartPadding.top +
          chartHeight -
          (normalized * chartHeight).clamp(0, chartHeight).toDouble();
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
            lineColor.withOpacity(0.28),
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

    final linePath = Path()..moveTo(chartPoints.first.dx, chartPoints.first.dy);
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

    for (final point in chartPoints) {
      canvas.drawCircle(point, 4.5, pointFillPaint);
      canvas.drawCircle(point, 4.5, pointStrokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressLineChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.lineColor != lineColor;
  }
}
