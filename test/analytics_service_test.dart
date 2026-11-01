import 'package:createiq/models/post.dart';
import 'package:createiq/services/analytics_service.dart';
import 'package:createiq/services/mock_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 31, 12);

  Post post(int daysAgo, {int likes = 100, int comments = 10, int shares = 5, int saves = 5, int hour = 18}) => Post(
        id: 'p$daysAgo-$hour',
        platform: SocialPlatform.instagram,
        type: PostType.reel,
        date: DateTime(now.year, now.month, now.day - daysAgo, hour),
        caption: 'test',
        likes: likes,
        comments: comments,
        shares: shares,
        saves: saves,
        followersAtPost: 1000,
      );

  test('engagement rate = (likes + comments + shares + saves) / followers × 100', () {
    expect(post(0).engagementRate, closeTo(12.0, 1e-9)); // 120 / 1000 × 100
  });

  test('totals, averages and top post are computed for the selected range', () {
    final posts = [post(1), post(2, likes: 300), post(40, likes: 999)];
    final s = AnalyticsService.compute(allPosts: posts, days: 30, followers: 1000, now: now);

    expect(s.postCount, 2); // the 40-day-old post is outside the range
    expect(s.totalLikes, 400);
    expect(s.avgLikes, 200);
    expect(s.topPost?.likes, 300);
    expect(s.daily.length, 30);
    expect(s.growthScore, inInclusiveRange(0, 100));
  });

  test('best time picks the highest-engagement weekday/slot', () {
    final posts = [post(1, hour: 9), post(2, likes: 900, hour: 21)];
    final s = AnalyticsService.compute(allPosts: posts, days: 7, followers: 1000, now: now);
    final best = posts[1].date;
    expect(s.bestWeekday, best.weekday - 1);
    expect(s.bestHour, 21);
  });

  test('empty input yields an empty summary without errors', () {
    final s = AnalyticsService.compute(allPosts: const [], days: 7, followers: 0, now: now);
    expect(s.isEmpty, isTrue);
    expect(s.engagementRate, 0);
    expect(s.topPost, isNull);
  });

  test('mock data is deterministic', () {
    expect(MockData.posts().map((p) => p.likes), MockData.posts().map((p) => p.likes));
  });
}
