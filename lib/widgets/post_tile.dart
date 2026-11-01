import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../models/post.dart';
import 'app_card.dart';
import 'platform_style.dart';

/// List row for a post: platform, caption, date, key metrics and engagement rate.
class PostTile extends StatelessWidget {
  const PostTile({
    super.key,
    required this.post,
    this.rank,
    this.onTap,
    this.trailing,
  });

  final Post post;

  /// Optional leaderboard position shown as a badge.
  final int? rank;
  final VoidCallback? onTap;

  /// Replaces the engagement-rate pill (e.g. edit/delete menu).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _Thumb(post: post, rank: rank),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.caption.isEmpty ? '${post.type.label} post' : post.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${post.platform.label} · ${post.type.label} · ${Fmt.shortDate(post.date)}',
                  style: context.text.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    _Metric(icon: LucideIcons.heart, value: post.likes),
                    _Metric(icon: LucideIcons.messageCircle, value: post.comments),
                    _Metric(icon: LucideIcons.share2, value: post.shares),
                    if (post.views > 0) _Metric(icon: LucideIcons.eye, value: post.views),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing ??
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  Fmt.percent(post.engagementRate),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.post, this.rank});

  final Post post;
  final int? rank;

  @override
  Widget build(BuildContext context) {
    // Local file previews aren't available on web.
    final hasImage = post.imagePath != null && !kIsWeb && File(post.imagePath!).existsSync();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        hasImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(File(post.imagePath!), width: 48, height: 48, fit: BoxFit.cover),
              )
            : PlatformBadge(platform: post.platform, size: 48),
        if (rank != null)
          Positioned(
            top: -6,
            left: -6,
            child: Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.cyan,
                shape: BoxShape.circle,
                border: Border.all(color: context.colors.surface, width: 2),
              ),
              child: Text(
                '$rank',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
              ),
            ),
          ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.value});

  final IconData icon;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: context.colors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(Fmt.compact(value), style: context.text.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
