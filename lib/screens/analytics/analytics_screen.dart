import 'package:fl_chart/fl_chart.dart';
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
import '../../models/post.dart';
import '../../providers/analytics_provider.dart';
import '../../widgets/chart_card.dart';
import '../../widgets/charts.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/platform_style.dart';
import '../../widgets/post_tile.dart';
import '../../widgets/section_header.dart';
import '../../widgets/shimmer_loading.dart';
import 'heatmap.dart';

/// Detailed analytics with platform / date-range filters and charts.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(analyticsFilterProvider);
    final analytics = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            tooltip: 'AI insights report',
            icon: const Icon(LucideIcons.fileText),
            onPressed: () => context.push(Routes.insights),
          ),
        ],
      ),
      body: Column(
        children: [
          _Filters(filter: filter),
          Expanded(
            child: analytics.when(
              loading: () => const ShimmerDashboard(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (s) => s.isEmpty
                  ? ListView(children: [
                      EmptyState(
                        icon: LucideIcons.lineChart,
                        title: 'Nothing to analyze',
                        message: 'No posts match this platform and date range. Try a wider range or add data.',
                        actionLabel: 'Add post data',
                        onAction: () => context.go(Routes.addData),
                      ),
                    ])
                  : _Charts(summary: s, days: filter.days),
            ),
          ),
        ],
      ),
    );
  }
}

class _Filters extends ConsumerWidget {
  const _Filters({required this.filter});

  final AnalyticsFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(analyticsFilterProvider.notifier);
    return Column(
      children: [
        // Platform chips.
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.gutter),
            children: [
              _chip(context, 'All', null, filter.platform == null, () => notifier.setPlatform(null)),
              for (final p in SocialPlatform.values)
                _chip(context, p.label, p.icon, filter.platform == p, () => notifier.setPlatform(p)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Date range selector.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.gutter),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<int>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 7, label: Text('7d')),
                ButtonSegment(value: 30, label: Text('30d')),
                ButtonSegment(value: 90, label: Text('90d')),
              ],
              selected: {filter.days},
              onSelectionChanged: (s) => notifier.setDays(s.first),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith(
                  (s) => s.contains(WidgetState.selected) ? AppColors.violet : null,
                ),
                foregroundColor: WidgetStateProperty.resolveWith(
                  (s) => s.contains(WidgetState.selected) ? Colors.white : null,
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusSmall)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _chip(BuildContext context, String label, IconData? icon, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: selected,
        onSelected: (_) => onTap(),
        avatar: icon == null
            ? null
            : Icon(icon, size: 16, color: selected ? AppColors.violet : context.colors.onSurfaceVariant),
        label: Text(label),
        labelStyle: TextStyle(
          color: selected ? AppColors.violet : context.colors.onSurface,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _Charts extends ConsumerStatefulWidget {
  const _Charts({required this.summary, required this.days});

  final AnalyticsSummary summary;
  final int days;

  @override
  ConsumerState<_Charts> createState() => _ChartsState();
}

class _ChartsState extends ConsumerState<_Charts> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.summary;
    final ranked = ref.watch(rankedPostsProvider);
    final visible = _showAll ? ranked : ranked.take(5).toList();
    const gap = SizedBox(height: AppConstants.gap);

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppConstants.gutter, 8, AppConstants.gutter, 32),
      children: [
        // Quick numbers.
        Row(
          children: [
            _MiniStat(label: 'Posts', value: '${s.postCount}'),
            _MiniStat(label: 'Avg likes', value: Fmt.compact(s.avgLikes)),
            _MiniStat(label: 'Avg comments', value: Fmt.compact(s.avgComments)),
            _MiniStat(label: 'Eng. rate', value: Fmt.percent(s.engagementRate)),
          ],
        ),
        gap,
        ChartCard(
          title: 'Likes & comments',
          subtitle: 'Last ${widget.days} days',
          legend: const Wrap(spacing: 16, children: [
            LegendDot(color: AppColors.violet, label: 'Likes'),
            LegendDot(color: AppColors.cyan, label: 'Comments'),
          ]),
          child: TrendLineChart(
            labels: s.daily.map((d) => Fmt.shortDate(d.day)).toList(),
            series: [
              LineSeries(label: 'Likes', color: AppColors.violet, values: s.daily.map((d) => d.likes.toDouble()).toList()),
              LineSeries(
                  label: 'Comments', color: AppColors.cyan, values: s.daily.map((d) => d.comments.toDouble()).toList()),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms),
        gap,
        ChartCard(
          title: 'Engagement by day of week',
          subtitle: 'Average engagement rate',
          height: 180,
          child: GradientBarChart(
            values: s.byWeekday,
            labels: AppConstants.weekdays,
            valueFormatter: (v) => Fmt.percent(v),
          ),
        ).animate().fadeIn(delay: 100.ms),
        gap,
        ChartCard(
          title: 'Content type performance',
          subtitle: 'Share of total interactions',
          height: 180,
          child: _TypePie(byType: s.byType),
        ).animate().fadeIn(delay: 200.ms),
        gap,
        ChartCard(
          title: 'Best time to post',
          subtitle: 'Best: ${AppConstants.weekdays[s.bestWeekday]} around ${Fmt.hour(s.bestHour)}',
          height: 250,
          child: EngagementHeatmap(summary: s),
        ).animate().fadeIn(delay: 300.ms),
        SectionHeader(
          title: 'Posts by engagement',
          actionLabel: ranked.length > 5 ? (_showAll ? 'Show less' : 'Show all (${ranked.length})') : null,
          onAction: () => setState(() => _showAll = !_showAll),
          padding: const EdgeInsets.only(top: 24, bottom: 8),
        ),
        for (final (i, p) in visible.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PostTile(post: p, rank: i + 1),
          ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 2),
          Text(label, style: context.text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

/// Donut chart of interactions per content type with a legend.
class _TypePie extends StatefulWidget {
  const _TypePie({required this.byType});

  final Map<PostType, int> byType;

  @override
  State<_TypePie> createState() => _TypePieState();
}

class _TypePieState extends State<_TypePie> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final entries = widget.byType.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (s, e) => s + e.value);
    if (total == 0) return const Center(child: Text('No interactions yet'));

    Color colorOf(PostType t) => AppColors.chartPalette[t.index % AppColors.chartPalette.length];

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 36,
              sectionsSpace: 3,
              pieTouchData: PieTouchData(
                touchCallback: (event, resp) => setState(() {
                  _touched = event.isInterestedForInteractions ? (resp?.touchedSection?.touchedSectionIndex ?? -1) : -1;
                }),
              ),
              sections: [
                for (final (i, e) in entries.indexed)
                  PieChartSectionData(
                    value: e.value.toDouble(),
                    color: colorOf(e.key),
                    radius: i == _touched ? 52 : 44,
                    title: '${(e.value / total * 100).round()}%',
                    titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final e in entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    LegendDot(color: colorOf(e.key), label: e.key.label),
                    const SizedBox(width: 8),
                    Text(Fmt.compact(e.value), style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
