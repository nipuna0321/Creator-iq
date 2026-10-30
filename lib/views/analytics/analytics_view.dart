import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../viewmodels/analytics_viewmodel.dart';
import '../../widgets/insight_card.dart';
import '../../widgets/post_card.dart';
import '../../widgets/platform_badge.dart';

class AnalyticsView extends StatelessWidget {
  final AnalyticsViewModel viewModel;

  const AnalyticsView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final vm = viewModel;
        final summary = vm.summary;

        if (vm.isLoading) {
          return const Scaffold(
            backgroundColor: AppTheme.background,
            body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Formula Info Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Content Analytics',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Deep performance comparisons & insights',
                            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => _showFormulaDialog(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceWhite,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.borderLight),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: const Icon(
                            Icons.help_outline_rounded,
                            size: 18,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Platform Filter Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: vm.platforms.map((plat) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: PlatformBadge(
                            platform: plat,
                            isSelected: vm.selectedPlatform == plat,
                            onTap: () => vm.setPlatform(plat),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Content Format Comparison Card (Median Engagement Rates)
                  _buildFormatComparisonCard(summary),
                  const SizedBox(height: 24),

                  // AI Content Intelligence & Evidence Section
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 18, color: AppTheme.primary),
                      SizedBox(width: 8),
                      Text(
                        'Explainable Insights & Findings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (summary.insights.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: const Center(
                        child: Text(
                          'Import at least 3 posts to generate data-driven recommendations.',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                    )
                  else
                    ...summary.insights.map((insight) => InsightCard(insight: insight)),

                  const SizedBox(height: 20),

                  // Ranked Post Performance List
                  const Text(
                    'Ranked by Engagement Rate',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...vm.filteredPosts.map((post) => PostCard(post: post)),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormatComparisonCard(dynamic summary) {
    final Map<String, double> medianByType = summary.medianEngagementByContentType;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(color: AppTheme.borderLight, width: 1.2),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Median Engagement by Format',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  'Robust to outliers',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (medianByType.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('No format breakdown available yet.'),
              ),
            )
          else ...[
            ...medianByType.entries.map((entry) {
              final double maxVal = 15.0; // Benchmark scale
              final double ratio = (entry.value / maxVal).clamp(0.05, 1.0);

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${entry.value.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        height: 8,
                        color: AppTheme.surfaceMuted,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: ratio,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppTheme.primary, AppTheme.secondary],
                                ),
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  void _showFormulaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusL)),
        title: const Row(
          children: [
            Icon(Icons.calculate_outlined, color: AppTheme.primary),
            SizedBox(width: 8),
            Text('Engagement Formula', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CreatorIQ calculates engagement rate relative to Reach:',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            SizedBox(height: 12),
            Center(
              child: Text(
                'Engagement Rate (%) = \n(Likes + Comments + Shares) / Reach × 100',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppTheme.primary,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              '• Uses Reach (unique viewers) instead of follower counts for platform fairness.\n'
              '• Medians are used rather than simple means to prevent rare viral outliers from skewing format insights.',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Understood', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

