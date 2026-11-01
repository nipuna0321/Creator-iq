import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/analytics_summary.dart';
import '../../models/user.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/posts_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/mock_data.dart';
import '../../widgets/app_card.dart';
import '../../widgets/avatar.dart';
import '../../widgets/chart_card.dart';
import '../../widgets/charts.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/post_tile.dart';
import '../../widgets/section_header.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/stat_card.dart';

/// Main dashboard: greeting, KPIs, 7-day chart, top post, AI tip and quick actions.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final overview = ref.watch(overviewProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: overview.when(
          loading: () => const ShimmerDashboard(),
          error: (e, _) => Center(child: Text('Something went wrong: $e')),
          data: (summary) => RefreshIndicator(
            color: AppColors.violet,
            onRefresh: () => ref.refresh(postsProvider.future),
            child: _Body(user: user, summary: summary),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.user, required this.summary});

  final User? user;
  final AnalyticsSummary summary;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    const g = AppConstants.gutter;
    final last7 = summary.daily.length > 7 ? summary.daily.sublist(summary.daily.length - 7) : summary.daily;
    // Rotate the tip daily.
    final tip = MockData.tipsOfTheDay[DateTime.now().day % MockData.tipsOfTheDay.length];

    return ListView(
      padding: const EdgeInsets.fromLTRB(g, 12, g, 32),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // --- Greeting ---
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$_greeting,', style: context.text.bodyLarge?.copyWith(color: context.colors.onSurfaceVariant)),
                  Text('${user?.firstName ?? 'Creator'} 👋',
                      style: context.text.headlineSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Insights',
              onPressed: () => context.push(Routes.insights),
              icon: const Icon(LucideIcons.fileText),
            ),
            GestureDetector(
              onTap: () => context.go(Routes.profile),
              child: Avatar(initials: user?.initials ?? '?', size: 46),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: 20),

        if (summary.isEmpty)
          EmptyState(
            icon: LucideIcons.barChart3,
            title: 'No data yet',
            message: 'Connect an account or add your first post to see your analytics here.',
            actionLabel: 'Add post data',
            onAction: () => context.go(Routes.addData),
          )
        else ...[
          _HeroCard(summary: summary).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: AppConstants.gap),
          _StatGrid(summary: summary),
          const SizedBox(height: AppConstants.gap),
          ChartCard(
            title: 'Engagement',
            subtitle: 'Last 7 days',
            height: 160,
            trailing: Text(
              Fmt.percent(summary.engagementRate),
              style: context.text.titleMedium?.copyWith(color: AppColors.violet, fontWeight: FontWeight.w800),
            ),
            child: TrendLineChart(
              labels: last7.map((d) => Fmt.weekday(d.day)).toList(),
              series: [
                LineSeries(
                  label: 'Engagement',
                  color: AppColors.violet,
                  values: last7.map((d) => d.engagementRate).toList(),
                ),
              ],
              valueFormatter: (v) => Fmt.percent(v),
            ),
          ).animate().fadeIn(delay: 200.ms),
          if (summary.topPost != null) ...[
            SectionHeader(
              title: 'Top performing post',
              actionLabel: 'See all',
              onAction: () => context.go(Routes.analytics),
              padding: const EdgeInsets.only(top: 20, bottom: 8),
            ),
            PostTile(post: summary.topPost!, rank: 1),
          ],
        ],
        const SizedBox(height: 20),
        _TipCard(tip: tip).animate().fadeIn(delay: 300.ms),
        const SectionHeader(title: 'Quick actions', padding: EdgeInsets.only(top: 20, bottom: 12)),
        Row(
          children: [
            _QuickAction(
              icon: LucideIcons.plusCircle,
              label: 'Add Post\nData',
              color: AppColors.violet,
              onTap: () => context.go(Routes.addData),
            ),
            const SizedBox(width: 12),
            _QuickAction(
              icon: LucideIcons.bot,
              label: 'Ask\nAI',
              color: AppColors.pink,
              onTap: () => context.push(Routes.chat),
            ),
            const SizedBox(width: 12),
            _QuickAction(
              icon: LucideIcons.sparkles,
              label: 'Generate\nContent',
              color: AppColors.cyan,
              onTap: () => context.go(Routes.aiStudio),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.summary});

  final AnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.zap, size: 18),
              const SizedBox(width: 6),
              Text('Last 30 days',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Score ${summary.growthScore}/100',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              Fmt.compact(summary.totalViews),
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, height: 1),
            ),
          ),
          const SizedBox(height: 4),
          Text('Total views across ${summary.postCount} posts',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85))),
          const SizedBox(height: 16),
          Row(
            children: [
              _HeroMetric(label: 'Shares', value: Fmt.compact(summary.totalShares)),
              _HeroMetric(label: 'Saves', value: Fmt.compact(summary.totalSaves)),
              _HeroMetric(label: 'Best day', value: AppConstants.weekdays[summary.bestWeekday]),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}

/// 2×2 KPI grid on phones, 4 across on wide screens.
class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.summary});

  final AnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final cards = [
      StatCard(
        label: 'Total Followers',
        value: Fmt.compact(summary.totalFollowers),
        icon: LucideIcons.users,
        change: summary.followersChange,
        color: AppColors.violet,
      ),
      StatCard(
        label: 'Total Likes',
        value: Fmt.compact(summary.totalLikes),
        icon: LucideIcons.heart,
        change: summary.likesChange,
        color: AppColors.pink,
      ),
      StatCard(
        label: 'Total Comments',
        value: Fmt.compact(summary.totalComments),
        icon: LucideIcons.messageCircle,
        change: summary.commentsChange,
        color: AppColors.cyan,
      ),
      StatCard(
        label: 'Engagement Rate',
        value: Fmt.percent(summary.engagementRate),
        icon: LucideIcons.trendingUp,
        change: summary.engagementChange,
        color: AppColors.warning,
      ),
    ];

    return LayoutBuilder(builder: (context, c) {
      final columns = c.maxWidth >= 600 ? 4 : 2;
      const spacing = 12.0;
      final width = (c.maxWidth - spacing * (columns - 1)) / columns;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final (i, card) in cards.indexed)
            SizedBox(width: width, child: card)
                .animate()
                .fadeIn(delay: (60 * i).ms, duration: 300.ms)
                .scaleXY(begin: 0.95, end: 1),
        ],
      );
    });
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});

  final String tip;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push(Routes.chat),
      border: Border.all(color: AppColors.cyan.withValues(alpha: 0.35)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(LucideIcons.lightbulb, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Tip of the Day', style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(tip, style: context.text.bodyMedium?.copyWith(height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w600, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}
