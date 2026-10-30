import '../models/social_post.dart';
import '../models/content_plan.dart';

class ValidationIssue {
  final int rowNumber;
  final String field;
  final String reason;

  const ValidationIssue({
    required this.rowNumber,
    required this.field,
    required this.reason,
  });
}

class ValidationReport {
  final bool isValid;
  final int totalRowsParsed;
  final int validRowsCount;
  final List<ValidationIssue> issues;
  final List<SocialPost> validPosts;

  const ValidationReport({
    required this.isValid,
    required this.totalRowsParsed,
    required this.validRowsCount,
    required this.issues,
    required this.validPosts,
  });
}

class SampleDataService {
  SampleDataService._();

  static const String sampleCsvRaw = '''id,platform,content_type,caption,published_at,views,reach,likes,comments,shares
p001,Instagram,Reel,Editing tutorial,2026-10-01T10:00:00,5200,4100,320,28,45
p002,YouTube,Video,Beginner data guide,2026-10-03T14:00:00,8200,6800,510,42,85
p003,TikTok,Video,Quick editing tip,2026-10-05T18:00:00,9100,7200,600,35,110
p004,Instagram,Carousel,Analytics checklist,2026-10-07T11:00:00,3400,2800,240,19,32
p005,YouTube,Short,Three creator mistakes,2026-10-09T16:00:00,6500,5400,420,31,66
p006,TikTok,Reel,Sound design secrets,2026-10-12T19:30:00,12400,9800,1120,84,210
p007,Instagram,Reel,Color grading in 60s,2026-10-15T12:00:00,7800,6200,650,49,95
p008,YouTube,Video,Full Studio Tour 2026,2026-10-18T15:00:00,15400,12800,1430,122,180
p009,TikTok,Short,Fast lighting setup,2026-10-21T17:00:00,8900,7100,780,56,120
p010,Instagram,Carousel,5 Content creation tools,2026-10-24T11:30:00,4600,3900,380,26,48''';

  static List<SocialPost> getInitialPosts() {
    return [
      SocialPost(
        id: 'p001',
        platform: 'Instagram',
        contentType: 'Reel',
        caption: 'Speed editing tutorial in Premiere Pro 🎬',
        publishedAt: DateTime(2026, 10, 1, 10, 0),
        views: 5200,
        reach: 4100,
        likes: 320,
        comments: 28,
        shares: 45,
        watchTimeSeconds: 42.5,
      ),
      SocialPost(
        id: 'p002',
        platform: 'YouTube',
        contentType: 'Video',
        caption: 'The Complete Creator Data & Growth Guide 2026',
        publishedAt: DateTime(2026, 10, 3, 14, 0),
        views: 8200,
        reach: 6800,
        likes: 510,
        comments: 42,
        shares: 85,
        watchTimeSeconds: 380.0,
      ),
      SocialPost(
        id: 'p003',
        platform: 'TikTok',
        contentType: 'Short',
        caption: 'Quick audio trick to boost viewer retention ⚡',
        publishedAt: DateTime(2026, 10, 5, 18, 0),
        views: 9100,
        reach: 7200,
        likes: 600,
        comments: 35,
        shares: 110,
        watchTimeSeconds: 22.0,
      ),
      SocialPost(
        id: 'p004',
        platform: 'Instagram',
        contentType: 'Carousel',
        caption: '7 Metrics every creator should measure weekly 📊',
        publishedAt: DateTime(2026, 10, 7, 11, 0),
        views: 3400,
        reach: 2800,
        likes: 240,
        comments: 19,
        shares: 32,
      ),
      SocialPost(
        id: 'p005',
        platform: 'YouTube',
        contentType: 'Short',
        caption: '3 common beginner editing mistakes to avoid!',
        publishedAt: DateTime(2026, 10, 9, 16, 0),
        views: 6500,
        reach: 5400,
        likes: 420,
        comments: 31,
        shares: 66,
        watchTimeSeconds: 28.0,
      ),
      SocialPost(
        id: 'p006',
        platform: 'TikTok',
        contentType: 'Reel',
        caption: 'Sound design secrets that make videos feel cinematic',
        publishedAt: DateTime(2026, 10, 12, 19, 30),
        views: 12400,
        reach: 9800,
        likes: 1120,
        comments: 84,
        shares: 210,
        watchTimeSeconds: 45.0,
      ),
      SocialPost(
        id: 'p007',
        platform: 'Instagram',
        contentType: 'Reel',
        caption: 'Color grading tutorial in under 60 seconds 🎨',
        publishedAt: DateTime(2026, 10, 15, 12, 0),
        views: 7800,
        reach: 6200,
        likes: 650,
        comments: 49,
        shares: 95,
        watchTimeSeconds: 58.0,
      ),
      SocialPost(
        id: 'p008',
        platform: 'YouTube',
        contentType: 'Video',
        caption: 'My Minimalist Desk & Camera Setup for 2026',
        publishedAt: DateTime(2026, 10, 18, 15, 0),
        views: 15400,
        reach: 12800,
        likes: 1430,
        comments: 122,
        shares: 180,
        watchTimeSeconds: 510.0,
      ),
    ];
  }

  static List<ContentPlan> getInitialPlans() {
    final now = DateTime.now();
    return [
      ContentPlan(
        id: 'plan_01',
        topic: 'How to Build a Custom Lighting Rig on a \$50 Budget',
        platform: 'YouTube',
        contentType: 'Video',
        scheduledDate: now.add(const Duration(days: 1)),
        status: ContentPlanStatus.readyToPublish,
        rationale: 'Hardware tutorials generated the longest watch time (avg 510s) and high save ratios.',
        notes: 'Include links to affordable LED panels and diffusers in description.',
        targetMetric: 'Target: 10K Views, 800+ Likes',
      ),
      ContentPlan(
        id: 'plan_02',
        topic: '3 Keyframing Shortcuts You Will Use Everyday',
        platform: 'Instagram',
        contentType: 'Reel',
        scheduledDate: now.add(const Duration(days: 3)),
        status: ContentPlanStatus.inProduction,
        rationale: 'Reel tutorials achieved 9.6% median engagement vs 4.8% for carousels.',
        notes: 'Record screen capture at 60fps with clear keypress overlay.',
        targetMetric: 'Target: 8.5K Reach, 120 Shares',
      ),
      ContentPlan(
        id: 'plan_03',
        topic: 'Before vs After: Audio Denoise in DaVinci Resolve',
        platform: 'TikTok',
        contentType: 'Short',
        scheduledDate: now.add(const Duration(days: 4)),
        status: ContentPlanStatus.planned,
        rationale: 'Audio comparison clips have viral sharing velocity on short-form feeds.',
        notes: 'Wear headphones banner in first 2 seconds.',
        targetMetric: 'Target: 15K Views',
      ),
      ContentPlan(
        id: 'plan_04',
        topic: 'Top 5 Free Royalty-Free Music Resources for Creators',
        platform: 'Instagram',
        contentType: 'Carousel',
        scheduledDate: now.add(const Duration(days: 6)),
        status: ContentPlanStatus.planned,
        rationale: 'High bookmark and save intent for resource guides.',
        notes: 'Slide 1 hook needs high contrast bold text.',
        targetMetric: 'Target: 300+ Saves',
      ),
    ];
  }

  /// Parses CSV text and provides thorough validation reports.
  static ValidationReport parseAndValidateCsv(String csvContent) {
    final lines = csvContent
        .split(RegExp(r'\r?\n'))
        .where((line) => line.trim().isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return const ValidationReport(
        isValid: false,
        totalRowsParsed: 0,
        validRowsCount: 0,
        issues: [ValidationIssue(rowNumber: 0, field: 'file', reason: 'CSV file is completely empty')],
        validPosts: [],
      );
    }

    final headerLine = lines.first;
    final headers = headerLine.split(',').map((h) => h.trim().toLowerCase()).toList();

    final expectedHeaders = [
      'id',
      'platform',
      'content_type',
      'caption',
      'published_at',
      'views',
      'reach',
      'likes',
      'comments',
      'shares'
    ];

    final missingHeaders = expectedHeaders.where((h) => !headers.contains(h)).toList();
    if (missingHeaders.isNotEmpty) {
      return ValidationReport(
        isValid: false,
        totalRowsParsed: lines.length - 1,
        validRowsCount: 0,
        issues: [
          ValidationIssue(
            rowNumber: 1,
            field: 'header',
            reason: 'Missing required columns: ${missingHeaders.join(', ')}',
          )
        ],
        validPosts: [],
      );
    }

    final idIdx = headers.indexOf('id');
    final platformIdx = headers.indexOf('platform');
    final typeIdx = headers.indexOf('content_type');
    final captionIdx = headers.indexOf('caption');
    final publishedIdx = headers.indexOf('published_at');
    final viewsIdx = headers.indexOf('views');
    final reachIdx = headers.indexOf('reach');
    final likesIdx = headers.indexOf('likes');
    final commentsIdx = headers.indexOf('comments');
    final sharesIdx = headers.indexOf('shares');

    final List<ValidationIssue> issues = [];
    final List<SocialPost> validPosts = [];

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i];
      final cols = line.split(',').map((c) => c.trim()).toList();

      if (cols.length < headers.length) {
        issues.add(ValidationIssue(
          rowNumber: i + 1,
          field: 'columns',
          reason: 'Expected ${headers.length} columns, found ${cols.length}',
        ));
        continue;
      }

      final id = cols[idIdx];
      final platform = cols[platformIdx];
      final contentType = cols[typeIdx];
      final caption = cols[captionIdx];
      final publishedStr = cols[publishedIdx];

      if (id.isEmpty) {
        issues.add(ValidationIssue(rowNumber: i + 1, field: 'id', reason: 'ID cannot be empty'));
        continue;
      }

      final publishedAt = DateTime.tryParse(publishedStr);
      if (publishedAt == null) {
        issues.add(ValidationIssue(
          rowNumber: i + 1,
          field: 'published_at',
          reason: 'Invalid date format: "$publishedStr"',
        ));
        continue;
      }

      final views = int.tryParse(cols[viewsIdx]);
      final reach = int.tryParse(cols[reachIdx]);
      final likes = int.tryParse(cols[likesIdx]);
      final comments = int.tryParse(cols[commentsIdx]);
      final shares = int.tryParse(cols[sharesIdx]);

      if (views == null || views < 0) {
        issues.add(ValidationIssue(rowNumber: i + 1, field: 'views', reason: 'Views must be non-negative integer'));
        continue;
      }
      if (reach == null || reach < 0) {
        issues.add(ValidationIssue(rowNumber: i + 1, field: 'reach', reason: 'Reach must be non-negative integer'));
        continue;
      }
      if (likes == null || likes < 0) {
        issues.add(ValidationIssue(rowNumber: i + 1, field: 'likes', reason: 'Likes must be non-negative integer'));
        continue;
      }
      if (comments == null || comments < 0) {
        issues.add(ValidationIssue(rowNumber: i + 1, field: 'comments', reason: 'Comments must be non-negative integer'));
        continue;
      }
      if (shares == null || shares < 0) {
        issues.add(ValidationIssue(rowNumber: i + 1, field: 'shares', reason: 'Shares must be non-negative integer'));
        continue;
      }

      validPosts.add(SocialPost(
        id: id,
        platform: platform.isEmpty ? 'Other' : platform,
        contentType: contentType.isEmpty ? 'Post' : contentType,
        caption: caption,
        publishedAt: publishedAt,
        views: views,
        reach: reach,
        likes: likes,
        comments: comments,
        shares: shares,
      ));
    }

    return ValidationReport(
      isValid: issues.isEmpty,
      totalRowsParsed: lines.length - 1,
      validRowsCount: validPosts.length,
      issues: issues,
      validPosts: validPosts,
    );
  }
}

