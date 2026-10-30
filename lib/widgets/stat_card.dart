import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import 'app_card.dart';

/// A KPI tile: icon, label, large value and an up/down % change.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.change,
    this.color = AppColors.violet,
  });

  final String label;
  final String value;
  final IconData icon;

  /// Percent change vs previous period; hidden when null.
  final double? change;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final up = (change ?? 0) >= 0;
    final changeColor = up ? AppColors.success : AppColors.danger;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              if (change != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: changeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(up ? LucideIcons.arrowUpRight : LucideIcons.arrowDownRight,
                          size: 12, color: changeColor),
                      const SizedBox(width: 2),
                      Text(
                        Fmt.change(change!).replaceFirst('+', ''),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: changeColor),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 2),
          Text(label, style: context.text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
