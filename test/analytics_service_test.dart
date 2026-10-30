import 'package:flutter_test/flutter_test.dart';
import 'package:creator_iq/models/social_post.dart';
import 'package:creator_iq/services/analytics_service.dart';
import 'package:creator_iq/services/sample_data_service.dart';

void main() {
  group('SocialPost Model Tests', () {
    test('Calculates total interactions correctly', () {
      final post = SocialPost(
        id: 'test_1',
        platform: 'Instagram',
        contentType: 'Reel',
        caption: 'Test post',
        publishedAt: DateTime(2026, 10, 1),
        views: 5000,
        reach: 4000,
        likes: 300,
        comments: 50,
        shares: 50,
      );

      expect(post.totalInteractions, equals(400));
    });

    test('Calculates engagement rate by reach correctly', () {
      final post = SocialPost(
        id: 'test_2',
        platform: 'YouTube',
        contentType: 'Video',
        caption: 'Test video',
        publishedAt: DateTime(2026, 10, 2),
        views: 10000,
        reach: 5000,
        likes: 400,
        comments: 50,
        shares: 50,
      );

      // (500 / 5000) * 100 = 10.0%
      expect(post.engagementRateByReach, closeTo(10.0, 0.01));
      expect(post.formattedEngagement, equals('10.0%'));
    });

    test('Returns null engagement rate when reach is zero or negative', () {
      final zeroReachPost = SocialPost(
        id: 'test_zero',
        platform: 'TikTok',
        contentType: 'Short',
        caption: 'Zero reach post',
        publishedAt: DateTime(2026, 10, 3),
        views: 0,
        reach: 0,
        likes: 10,
        comments: 0,
        shares: 0,
      );

      expect(zeroReachPost.engagementRateByReach, isNull);
      expect(zeroReachPost.formattedEngagement, equals('N/A'));
    });
  });

  group('AnalyticsService Calculations', () {
    late AnalyticsService service;

    setUp(() {
      service = AnalyticsService();
    });

    test('Calculates medians properly without outlier skew', () {
      final posts = [
        SocialPost(
          id: '1',
          platform: 'Instagram',
          contentType: 'Reel',
          caption: 'Regular post 1',
          publishedAt: DateTime.now(),
          views: 1000,
          reach: 1000,
          likes: 20,
          comments: 0,
          shares: 0, // 2.0%
        ),
        SocialPost(
          id: '2',
          platform: 'Instagram',
          contentType: 'Reel',
          caption: 'Regular post 2',
          publishedAt: DateTime.now(),
          views: 1000,
          reach: 1000,
          likes: 40,
          comments: 0,
          shares: 0, // 4.0%
        ),
        SocialPost(
          id: '3',
          platform: 'Instagram',
          contentType: 'Reel',
          caption: 'Viral Outlier',
          publishedAt: DateTime.now(),
          views: 50000,
          reach: 50000,
          likes: 15000,
          comments: 0,
          shares: 0, // 30.0%
        ),
      ];

      final summary = service.calculateSummary(posts);
      // Sorted rates: 2.0%, 4.0%, 30.0% -> Median is 4.0%
      expect(summary.medianEngagementRate, closeTo(4.0, 0.01));
      // Mean would be (2 + 4 + 30) / 3 = 12.0%
      expect(summary.averageEngagementRate, closeTo(12.0, 0.01));
    });

    test('Filters metrics by platform correctly', () {
      final posts = [
        SocialPost(
          id: 'ig_1',
          platform: 'Instagram',
          contentType: 'Reel',
          caption: 'IG Post',
          publishedAt: DateTime.now(),
          views: 2000,
          reach: 1500,
          likes: 100,
          comments: 10,
          shares: 10,
        ),
        SocialPost(
          id: 'yt_1',
          platform: 'YouTube',
          contentType: 'Video',
          caption: 'YT Video',
          publishedAt: DateTime.now(),
          views: 8000,
          reach: 6000,
          likes: 500,
          comments: 40,
          shares: 20,
        ),
      ];

      final igSummary = service.calculateSummary(posts, platformFilter: 'Instagram');
      expect(igSummary.totalPosts, equals(1));
      expect(igSummary.totalViews, equals(2000));

      final allSummary = service.calculateSummary(posts, platformFilter: 'All');
      expect(allSummary.totalPosts, equals(2));
      expect(allSummary.totalViews, equals(10000));
    });
  });

  group('CSV Parsing and Validation Tests', () {
    test('Successfully parses valid sample CSV', () {
      final report = SampleDataService.parseAndValidateCsv(SampleDataService.sampleCsvRaw);
      expect(report.isValid, isTrue);
      expect(report.validRowsCount, equals(10));
      expect(report.issues, isEmpty);
    });

    test('Detects missing required headers', () {
      const invalidCsv = 'id,platform,caption\n1,Instagram,Hello';
      final report = SampleDataService.parseAndValidateCsv(invalidCsv);
      expect(report.isValid, isFalse);
      expect(report.issues.first.field, equals('header'));
    });

    test('Detects invalid negative numeric values', () {
      const negativeMetricsCsv = '''id,platform,content_type,caption,published_at,views,reach,likes,comments,shares
p1,Instagram,Reel,Testing,2026-10-01T10:00:00,-500,100,10,2,1''';

      final report = SampleDataService.parseAndValidateCsv(negativeMetricsCsv);
      expect(report.isValid, isFalse);
      expect(report.issues.first.field, equals('views'));
    });
  });
}

