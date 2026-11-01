import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

/// Shimmering placeholder block.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({super.key, this.height = 100, this.width = double.infinity, this.radius});

  final double height;
  final double width;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Shimmer.fromColors(
      baseColor: dark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE9E7F2),
      highlightColor: dark ? Colors.white.withValues(alpha: 0.14) : const Color(0xFFF7F6FB),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius ?? AppConstants.radius),
        ),
      ),
    );
  }
}

/// Generic page-loading skeleton: a hero block, a 2×2 grid and a few rows.
class ShimmerDashboard extends StatelessWidget {
  const ShimmerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: AppConstants.gap, width: AppConstants.gap);
    return ListView(
      padding: const EdgeInsets.all(AppConstants.gutter),
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        ShimmerBox(height: 140),
        gap,
        Row(children: [Expanded(child: ShimmerBox(height: 110)), gap, Expanded(child: ShimmerBox(height: 110))]),
        gap,
        Row(children: [Expanded(child: ShimmerBox(height: 110)), gap, Expanded(child: ShimmerBox(height: 110))]),
        gap,
        ShimmerBox(height: 220),
        gap,
        ShimmerBox(height: 80),
      ],
    );
  }
}

/// Stack of shimmering list rows.
class ShimmerList extends StatelessWidget {
  const ShimmerList({super.key, this.count = 3, this.itemHeight = 90});

  final int count;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ShimmerBox(height: itemHeight),
        ),
      ),
    );
  }
}
