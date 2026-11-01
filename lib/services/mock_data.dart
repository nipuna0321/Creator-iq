import 'dart:math';

import '../models/post.dart';
import '../models/social_account.dart';
import '../models/user.dart';

/// Deterministic sample data so the app looks alive before a backend exists.
class MockData {
  MockData._();

  /// Follower counts per platform for the demo creator.
  static const Map<SocialPlatform, int> followers = {
    SocialPlatform.instagram: 48200,
    SocialPlatform.tiktok: 91500,
    SocialPlatform.youtube: 23800,
    SocialPlatform.facebook: 12100,
    SocialPlatform.x: 8400,
  };

  static const Map<SocialPlatform, String> handles = {
    SocialPlatform.instagram: '@alexcreates',
    SocialPlatform.tiktok: '@alex.creates',
    SocialPlatform.youtube: 'Alex Creates',
    SocialPlatform.facebook: 'Alex Creates',
    SocialPlatform.x: '@alexcreates',
  };

  /// A fully connected demo account set.
  static List<SocialAccount> accounts({bool connected = false}) => SocialPlatform.values
      .map((p) => SocialAccount(
            platform: p,
            handle: handles[p]!,
            followers: followers[p]!,
            connected: connected,
          ))
      .toList();

  static User demoUser({String name = 'Alex Rivera', String email = 'alex@createiq.app'}) => User(
        id: 'u_demo',
        name: name,
        email: email,
        niche: 'Fitness',
        bio: 'Helping busy people get fit in 20 minutes a day.',
        accounts: accounts(),
      );

  static const List<String> _captions = [
    '5-minute morning stretch that changed my day',
    'What I eat in a day — high protein edition',
    'Beginner home workout, no equipment needed',
    'My honest review of the new running shoes',
    'Behind the scenes of today\'s shoot',
    '3 mistakes I made when I started lifting',
    'Quick healthy breakfast under 10 minutes',
    'Q&A: answering your top fitness questions',
    'Transformation update — 12 weeks in',
    'Leg day finisher you can do anywhere',
    'Meal prep Sunday: 5 lunches for the week',
    'Why rest days matter more than you think',
  ];

  /// Generates ~45 posts spread over the last 90 days.
  ///
  /// The random seed is fixed so charts look the same on every launch.
  static List<Post> posts() {
    final rnd = Random(42);
    final now = DateTime.now();
    final result = <Post>[];
    const preferredHours = [7, 9, 12, 13, 17, 18, 19, 20, 21];

    for (var i = 0; i < 45; i++) {
      final platform = SocialPlatform.values[rnd.nextInt(SocialPlatform.values.length)];
      final type = _typeFor(platform, rnd);
      final daysAgo = (i * 2) + rnd.nextInt(2);
      final hour = preferredHours[rnd.nextInt(preferredHours.length)];
      final date = DateTime(now.year, now.month, now.day - daysAgo, hour, rnd.nextInt(60));

      final base = followers[platform]!;
      // Evenings, weekends and video content get a performance boost.
      var boost = 1.0;
      if (hour >= 17) boost += 0.35;
      if (date.weekday >= DateTime.friday) boost += 0.25;
      if (type == PostType.reel || type == PostType.video) boost += 0.4;
      // Gentle upward trend: recent posts do a little better.
      boost *= 1 + (90 - daysAgo) / 300;

      final likes = (base * (0.025 + rnd.nextDouble() * 0.03) * boost).round();
      final comments = (likes * (0.03 + rnd.nextDouble() * 0.05)).round();
      final shares = (likes * (0.02 + rnd.nextDouble() * 0.06)).round();
      final saves = (likes * (0.04 + rnd.nextDouble() * 0.08)).round();
      final views = (likes * (6 + rnd.nextDouble() * 10)).round();

      result.add(Post(
        id: 'mock_$i',
        platform: platform,
        type: type,
        date: date,
        caption: _captions[rnd.nextInt(_captions.length)],
        likes: likes,
        comments: comments,
        shares: shares,
        views: views,
        saves: saves,
        followersGained: (likes * (0.01 + rnd.nextDouble() * 0.03)).round(),
        followersAtPost: base,
      ));
    }
    return result;
  }

  static PostType _typeFor(SocialPlatform p, Random rnd) {
    switch (p) {
      case SocialPlatform.youtube:
        return rnd.nextBool() ? PostType.video : PostType.reel;
      case SocialPlatform.tiktok:
        return PostType.video;
      case SocialPlatform.x:
        return PostType.image;
      case SocialPlatform.instagram:
      case SocialPlatform.facebook:
        return PostType.values[rnd.nextInt(PostType.values.length)];
    }
  }

  static const List<String> tipsOfTheDay = [
    'Posts with a question in the first line get ~2× more comments. Try ending your next caption with one.',
    'Your Reels outperform static images. Repurpose your best carousel into a 15-second Reel this week.',
    'Your audience is most active in the evening. Schedule your next post between 6 PM and 8 PM.',
    'Reply to every comment within the first hour — it signals the algorithm your post is worth pushing.',
    'Consistency beats volume: 4 posts a week on fixed days usually beats 7 random ones.',
    'Save-worthy content (tips, checklists, recipes) drives reach. Add a "save this for later" CTA.',
  ];
}
