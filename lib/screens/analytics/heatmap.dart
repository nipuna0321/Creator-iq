import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/analytics_summary.dart';

/// 7 × 6 grid of weekday × time-of-day, coloured by average engagement rate.
/// The best cell is outlined.
class EngagementHeatmap extends StatelessWidget {
  const EngagementHeatmap({super.key, required this.summary});

  final AnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final grid = summary.heatmap;
    final maxV = grid.expand((r) => r).fold<double>(0, (a, b) => a > b ? a : b);
    final slots = AppConstants.timeSlots;
    final bestSlot = slots.indexWhere((s) => s.$1 == summary.bestHour);
    final muted = context.colors.onSurfaceVariant;
    final labelStyle = TextStyle(fontSize: 10, color: muted, fontWeight: FontWeight.w600);

    return Column(
      children: [
        // Time-slot header row.
        Row(
          children: [
            const SizedBox(width: 34),
            for (final s in slots) Expanded(child: Center(child: Text(s.$2, style: labelStyle))),
          ],
        ),
        const SizedBox(height: 6),
        for (var d = 0; d < 7; d++)
          Expanded(
            child: Row(
              children: [
                SizedBox(width: 34, child: Text(AppConstants.weekdays[d], style: labelStyle)),
                for (var s = 0; s < slots.length; s++)
                  Expanded(
                    child: Tooltip(
                      message: grid[d][s] == 0
                          ? 'No posts'
                          : '${AppConstants.weekdays[d]} ${Fmt.hour(slots[s].$1)}: ${Fmt.percent(grid[d][s])}',
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: grid[d][s] == 0
                              ? muted.withValues(alpha: 0.08)
                              : AppColors.violet.withValues(alpha: 0.15 + 0.85 * (grid[d][s] / maxV)),
                          borderRadius: BorderRadius.circular(6),
                          border: d == summary.bestWeekday && s == bestSlot && maxV > 0
                              ? Border.all(color: AppColors.pink, width: 2)
                              : null,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Low', style: labelStyle),
            const SizedBox(width: 6),
            for (final a in [0.15, 0.4, 0.65, 1.0])
              Container(
                width: 14,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: AppColors.violet.withValues(alpha: a),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            const SizedBox(width: 6),
            Text('High', style: labelStyle),
          ],
        ),
      ],
    );
  }
}
