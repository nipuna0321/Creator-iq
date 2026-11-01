import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';

/// A data series for [TrendLineChart].
class LineSeries {
  const LineSeries({required this.values, required this.color, required this.label});

  final List<double> values;
  final Color color;
  final String label;
}

/// Smooth line chart with gradient fill, used on Home and Analytics.
///
/// [labels] are x-axis labels (same length as each series); only some are
/// shown when there are many points.
class TrendLineChart extends StatelessWidget {
  const TrendLineChart({
    super.key,
    required this.series,
    required this.labels,
    this.valueFormatter,
    this.showLeftAxis = true,
  });

  final List<LineSeries> series;
  final List<String> labels;
  final String Function(double)? valueFormatter;
  final bool showLeftAxis;

  @override
  Widget build(BuildContext context) {
    final fmt = valueFormatter ?? (v) => Fmt.compact(v);
    final maxY = series.expand((s) => s.values).fold<double>(0, max);
    final top = maxY == 0 ? 1.0 : maxY * 1.2;
    final n = labels.length;
    final labelEvery = max(1, (n / 6).ceil());
    final muted = context.colors.onSurfaceVariant;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: top,
        minX: 0,
        maxX: max(0, n - 1).toDouble(),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: top / 4,
          getDrawingHorizontalLine: (_) => FlLine(color: muted.withValues(alpha: 0.12), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: showLeftAxis,
              reservedSize: 40,
              interval: top / 4,
              getTitlesWidget: (v, meta) => v == meta.max
                  ? const SizedBox.shrink()
                  : Text(fmt(v), style: TextStyle(fontSize: 10, color: muted)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 24,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= n || v != i.toDouble() || i % labelEvery != 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(labels[i], style: TextStyle(fontSize: 10, color: muted)),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => context.isDark ? const Color(0xFF26263F) : Colors.white,
            tooltipBorderRadius: BorderRadius.circular(12),
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem(
                      '${series[s.barIndex].label}: ${fmt(s.y)}',
                      TextStyle(color: series[s.barIndex].color, fontWeight: FontWeight.w700, fontSize: 12),
                    ))
                .toList(),
          ),
        ),
        lineBarsData: [
          for (final s in series)
            LineChartBarData(
              spots: [for (var i = 0; i < s.values.length; i++) FlSpot(i.toDouble(), s.values[i])],
              isCurved: true,
              preventCurveOverShooting: true,
              color: s.color,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: n <= 7),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [s.color.withValues(alpha: 0.25), s.color.withValues(alpha: 0)],
                ),
              ),
            ),
        ],
      ),
      duration: const Duration(milliseconds: 400),
    );
  }
}

/// Vertical bars with gradient fill; the highest bar is highlighted.
class GradientBarChart extends StatelessWidget {
  const GradientBarChart({super.key, required this.values, required this.labels, this.valueFormatter});

  final List<double> values;
  final List<String> labels;
  final String Function(double)? valueFormatter;

  @override
  Widget build(BuildContext context) {
    final fmt = valueFormatter ?? (v) => v.toStringAsFixed(1);
    final maxV = values.fold<double>(0, max);
    final muted = context.colors.onSurfaceVariant;

    return BarChart(
      BarChartData(
        maxY: maxV == 0 ? 1 : maxV * 1.2,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (v, meta) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(labels[v.toInt()], style: TextStyle(fontSize: 11, color: muted)),
              ),
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => context.isDark ? const Color(0xFF26263F) : Colors.white,
            tooltipBorderRadius: BorderRadius.circular(12),
            getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
              fmt(rod.toY),
              const TextStyle(color: AppColors.violet, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < values.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: values[i],
                width: 18,
                borderRadius: BorderRadius.circular(6),
                gradient: values[i] == maxV && maxV > 0
                    ? AppColors.primaryGradient
                    : LinearGradient(
                        colors: [AppColors.violet.withValues(alpha: 0.35), AppColors.violet.withValues(alpha: 0.2)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
              ),
            ]),
        ],
      ),
      duration: const Duration(milliseconds: 400),
    );
  }
}
