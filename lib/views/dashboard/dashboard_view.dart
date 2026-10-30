import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../widgets/animated_metric_card.dart';
import '../../widgets/custom_chart_widget.dart';
import '../../widgets/post_card.dart';
import '../../widgets/platform_badge.dart';

class DashboardView extends StatefulWidget {
  final DashboardViewModel viewModel;
  final Function(int) onNavigateTab;

  const DashboardView({
    super.key,
    required this.viewModel,
    required this.onNavigateTab,
  });

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  bool _showEngagementInChart = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;

        if (vm.isLoading) {
          return const Scaffold(
            backgroundColor: AppTheme.background,
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          );
        }

        final summary = vm.summary;

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: vm.refresh,
              color: AppTheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top App Header
                    _buildHeader(vm),
                    const SizedBox(height: 20),

                    // Quick Platform Filter Pills
                    _buildPlatformFilters(vm),
                    const SizedBox(height: 24),

                    // 4 Core Metrics Grid (White Cards with Counter Animations)
                    _buildMetricCards(summary),
                    const SizedBox(height: 24),

                    // Interactive Analytics Chart Card
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Performance Trend',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _showEngagementInChart = !_showEngagementInChart;
                            });
                          },
                          icon: Icon(
                            _showEngagementInChart ? Icons.visibility : Icons.auto_graph,
                            size: 16,
                            color: AppTheme.primary,
                          ),
                          label: Text(
                            _showEngagementInChart ? 'Show Views' : 'Show Engagement',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    CustomChartWidget(
                      posts: vm.allPosts,
                      showEngagementRate: _showEngagementInChart,
                    ),
                    const SizedBox(height: 24),

                    // Explainable Insight Banner Card
                    if (summary.insights.isNotEmpty) ...[
                      _buildInsightBanner(summary.insights.first),
                      const SizedBox(height: 24),
                    ],

                    // Top Performing Posts Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Top Performing Posts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => widget.onNavigateTab(2), // Jump to analytics
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (summary.topPosts.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceWhite,
                          borderRadius: BorderRadius.circular(AppTheme.radiusL),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.inbox_outlined, size: 40, color: AppTheme.textMuted),
                            const SizedBox(height: 12),
                            const Text(
                              'No posts imported yet',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Import a CSV export to generate your first insights.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => widget.onNavigateTab(1),
                              icon: const Icon(Icons.upload_file, size: 16),
                              label: const Text('Import CSV'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...summary.topPosts.take(3).map((post) => PostCard(post: post)),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(DashboardViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryLight,
              child: const Icon(Icons.person, color: AppTheme.primary, size: 28),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${vm.profile.name.split(' ').first}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  vm.profile.handle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.borderLight),
            boxShadow: AppTheme.cardShadow,
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            size: 20,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformFilters(DashboardViewModel vm) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: vm.availablePlatforms.map((platform) {
          final isSelected = vm.selectedPlatform == platform;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: PlatformBadge(
              platform: platform,
              isSelected: isSelected,
              onTap: () => vm.setPlatformFilter(platform),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricCards(dynamic summary) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AnimatedMetricCard(
                title: 'Total Views',
                value: summary.totalViews,
                icon: Icons.visibility_outlined,
                accentColor: AppTheme.primary,
                trendText: '+18.4%',
                isTrendPositive: true,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: AnimatedMetricCard(
                title: 'Total Reach',
                value: summary.totalReach,
                icon: Icons.campaign_outlined,
                accentColor: AppTheme.secondary,
                trendText: '+12.1%',
                isTrendPositive: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: AnimatedMetricCard(
                title: 'Median Engagement',
                value: summary.medianEngagementRate,
                isPercentage: true,
                icon: Icons.auto_graph_rounded,
                accentColor: AppTheme.success,
                trendText: '+3.2%',
                isTrendPositive: true,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: AnimatedMetricCard(
                title: 'Interactions',
                value: summary.totalInteractions,
                icon: Icons.favorite_border_rounded,
                accentColor: AppTheme.accentPink,
                trendText: '+24.5%',
                isTrendPositive: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsightBanner(dynamic topInsight) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 1.5),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.tips_and_updates, size: 16, color: AppTheme.primary),
              ),
              const SizedBox(width: 8),
              const Text(
                'AI Content Intelligence',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            topInsight.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            topInsight.recommendation,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => widget.onNavigateTab(3), // Navigate to Planner
            child: const Row(
              children: [
                Text(
                  'Add to Content Schedule',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 14, color: AppTheme.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

