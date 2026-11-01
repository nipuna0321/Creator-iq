import 'dart:math';

import '../core/constants/app_constants.dart';
import '../models/analytics_summary.dart';
import '../models/post.dart';

/// Pure functions that turn a list of posts into an [AnalyticsSummary].
///
/// Kept free of Flutter and Riverpod so it can be unit-tested or moved server-side.
class AnalyticsService {
  AnalyticsService._();

  /// Computes analytics for the last [days] days.
  ///
  /// [allPosts] should already be filtered by platform. Posts from the
  /// previous period of equal length are used for the % change values.
  static AnalyticsSummary compute({
    required List<Post> allPosts,
    required int days,
    required int followers,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final end = DateTime(today.year, today.month, today.day).add(const Duration(days: 1));
    final start = end.subtract(Duration(days: days));
    final prevStart = start.subtract(Duration(days: days));

    final current = allPosts.where((p) => !p.date.isBefore(start) && p.date.isBefore(end)).toList();
    final previous =
        allPosts.where((p) => !p.date.isBefore(prevStart) && p.date.isBefore(start)).toList();

    // --- Totals ---
    final likes = _sum(current, (p) => p.likes);
    final comments = _sum(current, (p) => p.comments);
    final shares = _sum(current, (p) => p.shares);
    final saves = _sum(current, (p) => p.saves);
    final views = _sum(current, (p) => p.views);
    final gained = _sum(current, (p) => p.followersGained);

    final er = _avgEngagement(current);
    final prevEr = _avgEngagement(previous);

    // Followers change = followers gained this period relative to the starting count.
    final startFollowers = max(1, followers - gained);
    final followersChange = followers == 0 ? 0.0 : gained / startFollowers * 100;

    // --- Daily series ---
    final daily = List.generate(days, (i) {
      final day = start.add(Duration(days: i));
      final onDay = current.where((p) => _sameDay(p.date, day)).toList();
      return DailyPoint(
        day: day,
        likes: _sum(onDay, (p) => p.likes),
        comments: _sum(onDay, (p) => p.comments),
        engagementRate: _avgEngagement(onDay),
      );
    });

    // --- Day of week ---
    final byWeekday = List.generate(7, (d) {
      return _avgEngagement(current.where((p) => p.date.weekday - 1 == d).toList());
    });

    // --- Content type ---
    final byType = {
      for (final t in PostType.values)
        t: _sum(current.where((p) => p.type == t).toList(), (p) => p.interactions),
    };

    // --- Heatmap (weekday × time slot) ---
    final slots = AppConstants.timeSlots;
    final buckets = List.generate(7, (_) => List.generate(slots.length, (_) => <double>[]));
    for (final p in current) {
      buckets[p.date.weekday - 1][slotFor(p.date.hour)].add(p.engagementRate);
    }
    final heatmap = buckets
        .map((row) => row.map((c) => c.isEmpty ? 0.0 : c.reduce((a, b) => a + b) / c.length).toList())
        .toList();

    // Best cell in the heatmap; default to Wednesday 6 PM with no data.
    var bestDay = 2, bestSlot = 4;
    var bestValue = -1.0;
    for (var d = 0; d < 7; d++) {
      for (var s = 0; s < slots.length; s++) {
        if (heatmap[d][s] > bestValue) {
          bestValue = heatmap[d][s];
          bestDay = d;
          bestSlot = s;
        }
      }
    }
    if (bestValue <= 0) {
      bestDay = 2;
      bestSlot = 4;
    }

    // --- Top post ---
    Post? top;
    for (final p in current) {
      if (top == null || p.engagementRate > top.engagementRate) top = p;
    }

    final engagementChange = _pctChange(er, prevEr);

    return AnalyticsSummary(
      postCount: current.length,
      totalFollowers: followers,
      totalLikes: likes,
      totalComments: comments,
      totalShares: shares,
      totalSaves: saves,
      totalViews: views,
      engagementRate: er,
      followersChange: followersChange,
      likesChange: _pctChange(likes.toDouble(), _sum(previous, (p) => p.likes).toDouble()),
      commentsChange: _pctChange(comments.toDouble(), _sum(previous, (p) => p.comments).toDouble()),
      engagementChange: engagementChange,
      avgLikes: current.isEmpty ? 0 : likes / current.length,
      avgComments: current.isEmpty ? 0 : comments / current.length,
      daily: daily,
      byWeekday: byWeekday,
      byType: byType,
      heatmap: heatmap,
      bestWeekday: bestDay,
      bestHour: slots[bestSlot].$1,
      growthScore: _growthScore(
        er: er,
        followersChange: followersChange,
        postsPerWeek: current.length / max(1, days / 7),
        engagementChange: engagementChange,
      ),
      topPost: top,
    );
  }

  /// Maps an hour (0–23) to an index in [AppConstants.timeSlots].
  /// Late-night hours (before 6 AM) fall into the last slot.
  static int slotFor(int hour) {
    final slots = AppConstants.timeSlots;
    for (var i = slots.length - 1; i >= 0; i--) {
      if (hour >= slots[i].$1) return i;
    }
    return slots.length - 1;
  }

  /// Weighted 0–100 score: engagement (40), follower growth (25),
  /// posting consistency (20) and engagement trend (15).
  static int _growthScore({
    required double er,
    required double followersChange,
    required double postsPerWeek,
    required double engagementChange,
  }) {
    final erPart = min(er / 6, 1.0) * 40;
    final growthPart = min(max(followersChange, 0) / 5, 1.0) * 25;
    final consistencyPart = min(postsPerWeek / 4, 1.0) * 20;
    final trendPart = ((engagementChange.clamp(-50, 50) + 50) / 100) * 15;
    return (erPart + growthPart + consistencyPart + trendPart).round().clamp(0, 100);
  }

  static int _sum(List<Post> posts, int Function(Post) pick) =>
      posts.fold(0, (total, p) => total + pick(p));

  static double _avgEngagement(List<Post> posts) => posts.isEmpty
      ? 0
      : posts.fold<double>(0, (total, p) => total + p.engagementRate) / posts.length;

  static double _pctChange(double current, double previous) {
    if (previous == 0) return current == 0 ? 0 : 100;
    return (current - previous) / previous * 100;
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
