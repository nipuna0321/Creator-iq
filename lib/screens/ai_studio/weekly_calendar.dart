import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/content_idea.dart';
import '../../widgets/app_card.dart';

/// Week view: a Mon–Sun day strip plus the suggested post for the selected day,
/// followed by the full week as a timeline.
class WeeklyCalendar extends StatefulWidget {
  const WeeklyCalendar({
    super.key,
    required this.items,
    required this.regenerating,
    required this.isSaved,
    required this.onCopy,
    required this.onSave,
    required this.onRegenerate,
  });

  final List<ContentIdea> items;
  final Set<String> regenerating;
  final bool Function(ContentIdea) isSaved;
  final ValueChanged<ContentIdea> onCopy;
  final ValueChanged<ContentIdea> onSave;
  final ValueChanged<ContentIdea> onRegenerate;

  @override
  State<WeeklyCalendar> createState() => _WeeklyCalendarState();
}

class _WeeklyCalendarState extends State<WeeklyCalendar> {
  int _selected = DateTime.now().weekday - 1;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day strip.
        Row(
          children: [
            for (var d = 0; d < 7; d++)
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selected = d),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: d == _selected ? AppColors.primaryGradient : null,
                      color: d == _selected ? null : context.colors.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Text(
                          AppConstants.weekdays[d].substring(0, 1),
                          style: TextStyle(
                            fontSize: 11,
                            color: d == _selected ? Colors.white70 : context.colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${monday.add(Duration(days: d)).day}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: d == _selected ? Colors.white : context.colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: d == _selected ? Colors.white : AppColors.pink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        for (final item in widget.items)
          _CalendarRow(
            item: item,
            highlighted: item.weekday == _selected,
            regenerating: widget.regenerating.contains(item.id),
            saved: widget.isSaved(item),
            onTap: () => setState(() => _selected = item.weekday ?? 0),
            onCopy: () => widget.onCopy(item),
            onSave: () => widget.onSave(item),
            onRegenerate: () => widget.onRegenerate(item),
          ).animate().fadeIn(delay: (60 * (item.weekday ?? 0)).ms),
      ],
    );
  }
}

class _CalendarRow extends StatelessWidget {
  const _CalendarRow({
    required this.item,
    required this.highlighted,
    required this.regenerating,
    required this.saved,
    required this.onTap,
    required this.onCopy,
    required this.onSave,
    required this.onRegenerate,
  });

  final ContentIdea item;
  final bool highlighted;
  final bool regenerating;
  final bool saved;
  final VoidCallback onTap;
  final VoidCallback onCopy;
  final VoidCallback onSave;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timeline day label.
            SizedBox(
              width: 44,
              child: Column(
                children: [
                  Text(AppConstants.weekdays[item.weekday ?? 0],
                      style: context.text.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: highlighted ? AppColors.violet : context.colors.onSurfaceVariant,
                      )),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Container(width: 2, color: AppColors.violet.withValues(alpha: highlighted ? 0.6 : 0.15)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AppCard(
                onTap: onTap,
                padding: const EdgeInsets.all(14),
                border: highlighted ? Border.all(color: AppColors.violet, width: 1.5) : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _pill(context, item.tags.isEmpty ? 'Post' : item.tags.first, AppColors.violet),
                        const SizedBox(width: 6),
                        if (item.suggestedTime != null)
                          _pill(context, item.suggestedTime!, AppColors.cyan, icon: LucideIcons.clock),
                        const Spacer(),
                        if (regenerating)
                          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(item.title, style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(item.body, style: context.text.bodySmall?.copyWith(height: 1.4)),
                    if (highlighted)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            tooltip: 'Copy',
                            visualDensity: VisualDensity.compact,
                            onPressed: onCopy,
                            icon: const Icon(LucideIcons.copy, size: 18),
                          ),
                          IconButton(
                            tooltip: saved ? 'Unsave' : 'Save',
                            visualDensity: VisualDensity.compact,
                            onPressed: onSave,
                            icon: Icon(saved ? LucideIcons.bookmarkMinus : LucideIcons.bookmarkPlus,
                                size: 18, color: saved ? AppColors.pink : null),
                          ),
                          IconButton(
                            tooltip: 'Regenerate',
                            visualDensity: VisualDensity.compact,
                            onPressed: regenerating ? null : onRegenerate,
                            icon: const Icon(LucideIcons.refreshCw, size: 18),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(BuildContext context, String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 11, color: color), const SizedBox(width: 4)],
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
