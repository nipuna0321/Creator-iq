import 'post.dart';

/// One point on a daily time series.
class DailyPoint {
  const DailyPoint({
    required this.day,
    this.likes = 0,
    this.comments = 0,
    this.engagementRate = 0,
  });

  final DateTime day;
  final int likes;
  final int comments;

  /// Average engagement rate of the posts on that day (0 when none).
  final double engagementRate;
}

/// Aggregated analytics computed from a set of posts.
class AnalyticsSummary {
  const AnalyticsSummary({
    required this.postCount,
    required this.totalFollowers,
    required this.totalLikes,
    required this.totalComments,
    required this.totalShares,
    required this.totalSaves,
    required this.totalViews,
    required this.engagementRate,
    required this.followersChange,
    required this.likesChange,
    required this.commentsChange,
    required this.engagementChange,
    required this.avgLikes,
    required this.avgComments,
    required this.daily,
    required this.byWeekday,
    required this.byType,
    required this.heatmap,
    required this.bestWeekday,
    required this.bestHour,
    required this.growthScore,
    this.topPost,
  });

  final int postCount;
  final int totalFollowers;
  final int totalLikes;
  final int totalComments;
  final int totalShares;
  final int totalSaves;
  final int totalViews;

  /// Average engagement rate across posts, in percent.
  final double engagementRate;

  // Percentage changes versus the previous period of equal length.
  final double followersChange;
  final double likesChange;
  final double commentsChange;
  final double engagementChange;

  final double avgLikes;
  final double avgComments;

  /// Daily series for line charts.
  final List<DailyPoint> daily;

  /// Average engagement rate per weekday, index 0 = Monday.
  final List<double> byWeekday;

  /// Total interactions per content type.
  final Map<PostType, int> byType;

  /// Average engagement rate per [weekday][timeSlot] (7 × 6 grid).
  final List<List<double>> heatmap;

  /// 0 = Monday … 6 = Sunday.
  final int bestWeekday;

  /// Hour of day (0–23) at the start of the best time slot.
  final int bestHour;

  /// Overall growth score, 0–100.
  final int growthScore;

  final Post? topPost;

  bool get isEmpty => postCount == 0;
}

/// AI-written performance report shown on the Insights screen.
class InsightReport {
  const InsightReport({
    required this.headline,
    required this.summary,
    required this.strengths,
    required this.weaknesses,
    required this.recommendations,
  });

  final String headline;
  final String summary;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendations;
}
