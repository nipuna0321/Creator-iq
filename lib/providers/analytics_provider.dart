import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/analytics_summary.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/analytics_service.dart';
import 'posts_provider.dart';
import 'user_provider.dart';

/// Filter state for the Analytics screen.
class AnalyticsFilter {
  const AnalyticsFilter({this.platform, this.days = 30});

  /// Null means "All platforms".
  final SocialPlatform? platform;
  final int days;

  @override
  bool operator ==(Object other) =>
      other is AnalyticsFilter && other.platform == platform && other.days == days;

  @override
  int get hashCode => Object.hash(platform, days);
}

class AnalyticsFilterNotifier extends Notifier<AnalyticsFilter> {
  @override
  AnalyticsFilter build() => const AnalyticsFilter();

  void setPlatform(SocialPlatform? p) => state = AnalyticsFilter(platform: p, days: state.days);
  void setDays(int d) => state = AnalyticsFilter(platform: state.platform, days: d);
}

final analyticsFilterProvider =
    NotifierProvider<AnalyticsFilterNotifier, AnalyticsFilter>(AnalyticsFilterNotifier.new);

/// Follower count for [platform] (or all platforms when null).
///
/// Uses connected account numbers; for platforms that only have manual
/// entries, falls back to the follower count on the latest manual post.
int followersFor(User? user, List<Post> posts, SocialPlatform? platform) {
  var total = 0;
  for (final p in SocialPlatform.values) {
    if (platform != null && p != platform) continue;
    final account = user?.accountFor(p);
    if (account != null && account.connected) {
      total += account.followers;
    } else {
      final manual = posts.where((post) => post.platform == p && post.isManual);
      if (manual.isNotEmpty) total += manual.first.followersAtPost; // posts are newest-first
    }
  }
  return total;
}

AnalyticsSummary _summarize(User? user, List<Post> posts, SocialPlatform? platform, int days) {
  final filtered = platform == null ? posts : posts.where((p) => p.platform == platform).toList();
  return AnalyticsService.compute(
    allPosts: filtered,
    days: days,
    followers: followersFor(user, posts, platform),
  );
}

/// Summary for the Analytics screen, driven by [analyticsFilterProvider].
final analyticsProvider = Provider<AsyncValue<AnalyticsSummary>>((ref) {
  final filter = ref.watch(analyticsFilterProvider);
  final user = ref.watch(userProvider);
  return ref.watch(postsProvider).whenData((posts) => _summarize(user, posts, filter.platform, filter.days));
});

/// 30-day all-platform summary used on Home, Insights and in AI chat.
final overviewProvider = Provider<AsyncValue<AnalyticsSummary>>((ref) {
  final user = ref.watch(userProvider);
  return ref.watch(postsProvider).whenData((posts) => _summarize(user, posts, null, 30));
});

/// Posts matching the analytics filter, sorted by engagement (best first).
final rankedPostsProvider = Provider<List<Post>>((ref) {
  final filter = ref.watch(analyticsFilterProvider);
  final posts = ref.watch(postsProvider).value ?? [];
  final since = DateTime.now().subtract(Duration(days: filter.days));
  return posts
      .where((p) => (filter.platform == null || p.platform == filter.platform) && p.date.isAfter(since))
      .toList()
    ..sort((a, b) => b.engagementRate.compareTo(a.engagementRate));
});
