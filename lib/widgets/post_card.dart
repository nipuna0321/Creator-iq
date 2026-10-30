import 'package:flutter/material.dart';
import '../models/social_post.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import 'platform_badge.dart';

class PostCard extends StatelessWidget {
  final SocialPost post;
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rate = post.engagementRateByReach;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(color: AppTheme.borderLight, width: 1.2),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Platform badge, Content type, Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        PlatformBadge(platform: post.platform),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceMuted,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            post.contentType,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      Formatters.dayAndMonth(post.publishedAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Caption
                Text(
                  post.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),

                // Divider line
                const Divider(height: 1, color: AppTheme.surfaceMuted),
                const SizedBox(height: 12),

                // Performance Metrics Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetricItem(
                      icon: Icons.visibility_outlined,
                      label: 'Views',
                      value: Formatters.compactNumber(post.views),
                    ),
                    _buildMetricItem(
                      icon: Icons.campaign_outlined,
                      label: 'Reach',
                      value: Formatters.compactNumber(post.reach),
                    ),
                    _buildMetricItem(
                      icon: Icons.favorite_border_rounded,
                      label: 'Likes',
                      value: Formatters.compactNumber(post.likes),
                    ),
                    _buildMetricItem(
                      icon: Icons.share_outlined,
                      label: 'Shares',
                      value: Formatters.compactNumber(post.shares),
                    ),
                    // Highlighted Engagement Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: (rate != null && rate >= 8.0)
                            ? AppTheme.successLight
                            : AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_graph_rounded,
                            size: 13,
                            color: (rate != null && rate >= 8.0)
                                ? AppTheme.success
                                : AppTheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.formattedEngagement,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: (rate != null && rate >= 8.0)
                                  ? AppTheme.success
                                  : AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: AppTheme.textMuted),
            const SizedBox(width: 3),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

