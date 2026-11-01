import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/content_idea.dart';
import '../../widgets/app_card.dart';

/// Result card for an AI-generated idea with Copy / Save / Regenerate actions.
class IdeaCard extends StatelessWidget {
  const IdeaCard({
    super.key,
    required this.idea,
    required this.saved,
    required this.onCopy,
    required this.onSave,
    this.onRegenerate,
    this.regenerating = false,
  });

  final ContentIdea idea;
  final bool saved;
  final VoidCallback onCopy;
  final VoidCallback onSave;

  /// Hidden when null (e.g. in the saved list).
  final VoidCallback? onRegenerate;
  final bool regenerating;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: regenerating ? 0.5 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_icon, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(idea.title, style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                ),
                if (regenerating)
                  const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
            const SizedBox(height: 12),
            if (idea.type == IdeaType.hashtags)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final tag in idea.tags)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(tag,
                          style: const TextStyle(color: AppColors.cyan, fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                ],
              )
            else ...[
              SelectableText(idea.body, style: context.text.bodyMedium?.copyWith(height: 1.5)),
              if (idea.tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: [
                    for (final tag in idea.tags)
                      Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        side: BorderSide.none,
                        backgroundColor: AppColors.violet.withValues(alpha: 0.08),
                      ),
                  ],
                ),
              ],
            ],
            const SizedBox(height: 8),
            const Divider(height: 16),
            Row(
              children: [
                _Action(icon: LucideIcons.copy, label: 'Copy', onTap: onCopy),
                _Action(
                  icon: saved ? LucideIcons.bookmarkMinus : LucideIcons.bookmarkPlus,
                  label: saved ? 'Saved' : 'Save',
                  onTap: onSave,
                  active: saved,
                ),
                if (onRegenerate != null)
                  _Action(
                    icon: LucideIcons.refreshCw,
                    label: 'Regenerate',
                    onTap: regenerating ? null : onRegenerate,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData get _icon => switch (idea.type) {
        IdeaType.postIdea => LucideIcons.lightbulb,
        IdeaType.caption => LucideIcons.type,
        IdeaType.hashtags => LucideIcons.hash,
        IdeaType.calendar => LucideIcons.calendar,
      };
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, required this.onTap, this.active = false});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.pink : context.colors.onSurfaceVariant;
    return Expanded(
      child: TextButton.icon(
        onPressed: onTap,
        style: TextButton.styleFrom(foregroundColor: color, padding: EdgeInsets.zero),
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
