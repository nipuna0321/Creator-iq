import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/social_post.dart';
import '../core/utils/formatters.dart';

class CustomChartWidget extends StatefulWidget {
  final List<SocialPost> posts;
  final String metricTitle; // e.g. "Views Over Recent Posts"
  final bool showEngagementRate;

  const CustomChartWidget({
    super.key,
    required this.posts,
    this.metricTitle = 'Recent Post Performance',
    this.showEngagementRate = false,
  });

  @override
  State<CustomChartWidget> createState() => _CustomChartWidgetState();
}

class _CustomChartWidgetState extends State<CustomChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _chartProgress;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _chartProgress = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant CustomChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showEngagementRate != widget.showEngagementRate ||
        oldWidget.posts.length != widget.posts.length) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.posts.isEmpty) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: const Text('No data available for chart'),
      );
    }

    // Limit to latest 7 posts for clean phone visualization
    final displayPosts = widget.posts.take(7).toList().reversed.toList();

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
          // Chart Header with Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.metricTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.showEngagementRate ? 'Engagement Rate (%) by post' : 'Views per post',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.showEngagementRate ? 'Engagement' : 'Views',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Custom Painted Bar Chart with Gesture Interaction
          SizedBox(
            height: 180,
            child: AnimatedBuilder(
              animation: _chartProgress,
              builder: (context, _) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onTapDown: (details) {
                        final barWidth = constraints.maxWidth / displayPosts.length;
                        final index = (details.localPosition.dx / barWidth).floor();
                        if (index >= 0 && index < displayPosts.length) {
                          setState(() {
                            _hoveredIndex = index;
                          });
                        }
                      },
                      child: CustomPaint(
                        size: Size(constraints.maxWidth, 180),
                        painter: _BarChartPainter(
                          posts: displayPosts,
                          progress: _chartProgress.value,
                          showEngagement: widget.showEngagementRate,
                          selectedIndex: _hoveredIndex,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Bottom labels
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: displayPosts.map((p) {
              return Text(
                Formatters.dayAndMonth(p.publishedAt),
                style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<SocialPost> posts;
  final double progress;
  final bool showEngagement;
  final int? selectedIndex;

  _BarChartPainter({
    required this.posts,
    required this.progress,
    required this.showEngagement,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (posts.isEmpty) return;

    final double maxVal = posts.fold<double>(1.0, (prev, p) {
      final val = showEngagement ? (p.engagementRateByReach ?? 0.0) : p.views.toDouble();
      return math.max(prev, val);
    }) * 1.15; // 15% breathing room at top

    // Draw grid lines
    final gridPaint = Paint()
      ..color = AppTheme.surfaceMuted
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 3; i++) {
      final y = size.height - (size.height * (i / 4));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final double slotWidth = size.width / posts.length;
    final double barWidth = math.min(slotWidth * 0.45, 28.0);

    for (int i = 0; i < posts.length; i++) {
      final post = posts[i];
      final val = showEngagement ? (post.engagementRateByReach ?? 0.0) : post.views.toDouble();
      final double normalizedHeight = (val / maxVal) * size.height * progress;

      final double x = (i * slotWidth) + (slotWidth - barWidth) / 2;
      final double y = size.height - normalizedHeight;

      final isSelected = selectedIndex == i;

      // Gradient fill for bar
      final Rect barRect = Rect.fromLTWH(x, y, barWidth, normalizedHeight);
      final RRect roundedBar = RRect.fromRectAndRadius(
        barRect,
        const Radius.circular(8),
      );

      final barGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isSelected
            ? [AppTheme.secondary, AppTheme.primary]
            : [AppTheme.primary.withOpacity(0.9), AppTheme.primary.withOpacity(0.65)],
      );

      final barPaint = Paint()..shader = barGradient.createShader(barRect);
      canvas.drawRRect(roundedBar, barPaint);

      // Tooltip/Value label when selected
      if (isSelected || (i == posts.length - 1 && selectedIndex == null)) {
        final labelText = showEngagement ? '${val.toStringAsFixed(1)}%' : Formatters.compactNumber(val.round());
        final textSpan = TextSpan(
          text: labelText,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(x + (barWidth - textPainter.width) / 2, y - 16),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.showEngagement != showEngagement;
  }
}

