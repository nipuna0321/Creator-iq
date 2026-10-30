import 'dart:math';

import '../core/constants/app_constants.dart';
import '../core/utils/formatters.dart';
import '../models/analytics_summary.dart';
import '../models/content_idea.dart';
import '../models/post.dart';
import '../models/questionnaire_answers.dart';
import '../models/social_account.dart';
import '../models/user.dart';
import 'mock_data.dart';

/// Gateway to the CreateIQ backend.
///
/// Every method currently returns mock data after a short delay. To connect a
/// real backend, replace each method body with an HTTP call to the matching
/// endpoint in [ApiEndpoints] (e.g. using `package:http` or `dio`). Callers
/// don't need to change.
class ApiService {
  ApiService({Random? random}) : _rnd = random ?? Random();

  final Random _rnd;

  Future<void> _latency([Duration d = AppConstants.aiDelay]) => Future.delayed(d);

  String _id() => '${DateTime.now().microsecondsSinceEpoch}_${_rnd.nextInt(1 << 20)}';

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------

  /// POST [ApiEndpoints.login]
  Future<User> login(String email, String password) async {
    await _latency(const Duration(milliseconds: 900));
    final name = _nameFromEmail(email);
    return MockData.demoUser(name: name, email: email);
  }

  /// POST [ApiEndpoints.signUp]
  Future<User> signUp(String name, String email, String password) async {
    await _latency(const Duration(milliseconds: 900));
    return MockData.demoUser(name: name, email: email);
  }

  /// POST [ApiEndpoints.googleSignIn]
  Future<User> signInWithGoogle() async {
    await _latency(const Duration(milliseconds: 900));
    return MockData.demoUser();
  }

  /// POST [ApiEndpoints.forgotPassword]
  Future<void> sendPasswordReset(String email) => _latency(const Duration(milliseconds: 700));

  // ---------------------------------------------------------------------------
  // Accounts & posts
  // ---------------------------------------------------------------------------

  /// POST [ApiEndpoints.connectAccount] — would start the platform's OAuth flow.
  Future<SocialAccount> connectAccount(SocialPlatform platform) async {
    await _latency(const Duration(milliseconds: 1200));
    return SocialAccount(
      platform: platform,
      handle: MockData.handles[platform]!,
      followers: MockData.followers[platform]!,
      connected: true,
    );
  }

  /// GET [ApiEndpoints.posts] — posts synced from connected platforms.
  Future<List<Post>> fetchPosts() async {
    await _latency(const Duration(milliseconds: 600));
    return MockData.posts();
  }

  // ---------------------------------------------------------------------------
  // AI
  // ---------------------------------------------------------------------------

  /// POST [ApiEndpoints.generateContent]
  ///
  /// Returns ideas of the requested [type] about [topic] written in [tone].
  Future<List<ContentIdea>> generateContent({
    required IdeaType type,
    required String topic,
    required Tone tone,
    String? niche,
  }) async {
    await _latency();
    final subject = topic.trim().isEmpty ? (niche ?? 'your niche').toLowerCase() : topic.trim();
    switch (type) {
      case IdeaType.postIdea:
        return _postIdeas(subject, tone);
      case IdeaType.caption:
        return _captions(subject, tone);
      case IdeaType.hashtags:
        return _hashtags(subject, niche);
      case IdeaType.calendar:
        return _calendar(subject, tone);
    }
  }

  /// POST [ApiEndpoints.askAI]
  ///
  /// Answers a free-form question using the user's analytics as context.
  Future<String> askAI(
    String question, {
    required AnalyticsSummary summary,
    QuestionnaireAnswers? answers,
    Post? lastPost,
  }) async {
    await _latency();
    final q = question.toLowerCase();
    final bestDay = AppConstants.weekdays[summary.bestWeekday];
    final bestTime = Fmt.hour(summary.bestHour);

    if (q.contains('poor') || q.contains('bad') || q.contains('perform') || q.contains('flop')) {
      if (lastPost == null) {
        return 'I don\'t see any posts yet. Add a post in **Add Data** and I\'ll break down how it did.';
      }
      final diff = summary.engagementRate == 0
          ? 0
          : (lastPost.engagementRate - summary.engagementRate) / summary.engagementRate * 100;
      final verdict = diff >= 0
          ? 'actually performed ${diff.toStringAsFixed(0)}% *above* your average engagement'
          : 'came in ${diff.abs().toStringAsFixed(0)}% below your average engagement';
      return 'Your last ${lastPost.platform.label} ${lastPost.type.label.toLowerCase()} '
          '("${lastPost.caption}") $verdict of ${Fmt.percent(summary.engagementRate)}.\n\n'
          'Likely factors:\n'
          '• Posted on ${Fmt.weekday(lastPost.date)} at ${Fmt.time(lastPost.date)} — your best slot is $bestDay around $bestTime.\n'
          '• ${lastPost.type == PostType.image ? 'Static images get less reach than your Reels and videos.' : 'The hook in the first 2 seconds decides retention — try a bolder opener.'}\n'
          '• Only ${lastPost.comments} comments — end with a direct question to spark replies.\n\n'
          'Try re-posting the idea as a short video at $bestTime on $bestDay.';
    }

    if (q.contains('when') || q.contains('time') || q.contains('schedule')) {
      return 'Based on your posts, your audience engages most on **$bestDay around $bestTime**.\n\n'
          'Other strong windows:\n'
          '• Weekday evenings (6–9 PM)\n'
          '• Weekend late mornings (9 AM–12 PM)\n\n'
          'Aim for ${answers?.postsPerWeek ?? 4} posts per week on consistent days so your audience learns when to expect you.';
    }

    if (q.contains('comment')) {
      return 'You average ${summary.avgComments.toStringAsFixed(0)} comments per post. To get more:\n\n'
          '1. End every caption with a specific question ("Which one would you pick — A or B?").\n'
          '2. Reply to every comment in the first 60 minutes.\n'
          '3. Pin a comment that starts a conversation.\n'
          '4. Try "comment X and I\'ll send you…" prompts for resources.\n'
          '5. Post controversial-but-friendly takes in your niche.';
    }

    if (q.contains('hashtag')) {
      return 'Use 5–10 hashtags per post: 2–3 broad (1M+ posts), 3–4 niche (50K–500K) and 1–2 branded. '
          'Rotate sets so you don\'t look spammy. Try the **Hashtags** tab in AI Studio for ready-made sets.';
    }

    if (q.contains('follow') || q.contains('grow')) {
      return 'You gained ${Fmt.change(summary.followersChange)} followers this period. To accelerate:\n\n'
          '• Double down on ${_bestType(summary).label}s — they drive your highest interactions.\n'
          '• Collaborate with a creator in ${answers?.niche ?? 'your niche'} of similar size.\n'
          '• Turn your top post into a series so new viewers have a reason to follow.';
    }

    return 'Great question! Here\'s a snapshot to work from:\n\n'
        '• Engagement rate: ${Fmt.percent(summary.engagementRate)} (${Fmt.change(summary.engagementChange)} vs last period)\n'
        '• Best time to post: $bestDay at $bestTime\n'
        '• Top content type: ${_bestType(summary).label}\n'
        '• Growth score: ${summary.growthScore}/100\n\n'
        'Ask me about posting times, comments, hashtags, or why a post underperformed.';
  }

  /// POST [ApiEndpoints.insights] — AI-written performance report.
  Future<InsightReport> generateInsights(AnalyticsSummary s, {QuestionnaireAnswers? answers}) async {
    await _latency();
    final bestType = _bestType(s);
    final strengths = <String>[
      if (s.engagementRate >= 3)
        'Strong engagement rate of ${Fmt.percent(s.engagementRate)} — above the 1–3% industry average.',
      '${bestType.label}s are your best format, driving the most interactions.',
      if (s.followersChange > 0) 'Steady follower growth (${Fmt.change(s.followersChange)}) this period.',
      if (s.totalSaves > s.totalShares) 'High save count shows your content is seen as valuable.',
    ];
    final weaknesses = <String>[
      if (s.avgComments < s.avgLikes * 0.05)
        'Comments are low relative to likes — people watch but don\'t talk.',
      if (s.engagementChange < 0)
        'Engagement dipped ${Fmt.change(s.engagementChange)} compared to the previous period.',
      if (s.postCount < 8) 'Posting frequency is inconsistent — only ${s.postCount} posts this period.',
      if ((s.byType[PostType.story] ?? 0) < (s.byType[bestType] ?? 0) * 0.2)
        'Stories are underused for building day-to-day connection.',
    ];
    if (weaknesses.isEmpty) weaknesses.add('No major weaknesses — keep testing new formats.');

    return InsightReport(
      headline: s.growthScore >= 70
          ? 'You\'re on a strong growth trajectory 🚀'
          : s.growthScore >= 45
              ? 'Solid foundation with room to grow 📈'
              : 'Let\'s build momentum together 💪',
      summary: 'Across ${s.postCount} posts you earned ${Fmt.compact(s.totalLikes)} likes and '
          '${Fmt.compact(s.totalComments)} comments with an average engagement rate of '
          '${Fmt.percent(s.engagementRate)}. Your audience is most active on '
          '${AppConstants.weekdays[s.bestWeekday]} around ${Fmt.hour(s.bestHour)}.',
      strengths: strengths,
      weaknesses: weaknesses,
      recommendations: [
        'Schedule key posts on ${AppConstants.weekdays[s.bestWeekday]} at ${Fmt.hour(s.bestHour)}.',
        'Publish at least 2 ${bestType.label}s per week.',
        'End captions with a question to lift comments.',
        if (answers?.goal == 'Sales') 'Add a soft product CTA to 1 in every 4 posts.',
        if (answers?.goal == 'Brand awareness') 'Partner with 1 creator per month for collabs.',
        'Reply to comments within the first hour of posting.',
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Mock generators
  // ---------------------------------------------------------------------------

  String _nameFromEmail(String email) {
    final local = email.split('@').first.replaceAll(RegExp(r'[._\-0-9]+'), ' ').trim();
    if (local.isEmpty) return 'Creator';
    return local.split(' ').map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1)).join(' ');
  }

  PostType _bestType(AnalyticsSummary s) {
    var best = PostType.reel;
    var value = -1;
    s.byType.forEach((t, v) {
      if (v > value) {
        value = v;
        best = t;
      }
    });
    return best;
  }

  T _pick<T>(List<T> items) => items[_rnd.nextInt(items.length)];

  List<T> _shuffled<T>(List<T> items) => [...items]..shuffle(_rnd);

  String _toneOpener(Tone tone) => _pick(switch (tone) {
        Tone.funny => ['Plot twist:', 'Nobody asked, but', 'Me pretending I have it together:', 'POV:'],
        Tone.professional => ['Here\'s what works:', 'Key insight:', 'A simple framework:', 'Data shows:'],
        Tone.inspiring => ['Your reminder today:', 'Small steps, big change.', 'Start where you are.', 'Believe it:'],
        Tone.casual => ['Okay so,', 'Real talk:', 'Quick one today —', 'Just sharing:'],
      });

  String _toneEmoji(Tone tone) => _pick(switch (tone) {
        Tone.funny => ['😂', '🙃', '🤪', '😅'],
        Tone.professional => ['📊', '✅', '📌', '💡'],
        Tone.inspiring => ['✨', '🌱', '🔥', '💫'],
        Tone.casual => ['🙌', '👀', '☕', '🤙'],
      });

  List<ContentIdea> _postIdeas(String topic, Tone tone) {
    final templates = _shuffled([
      ('Myth vs. Fact: $topic', 'Bust 3 common myths about $topic in a carousel. One myth per slide, fact on the next. Finish with "Which one surprised you?"'),
      ('Day-in-the-life: $topic', 'Film a 30-second Reel showing how $topic fits into your real day. Fast cuts, on-screen captions, trending audio.'),
      ('Beginner\'s guide to $topic', 'Break $topic into 5 simple steps for complete beginners. Make it save-worthy with a clean checklist design.'),
      ('Before & after: $topic', 'Show a transformation related to $topic. Hook: "I wish I knew this sooner…"'),
      ('Hot take on $topic', 'Share an unpopular opinion about $topic and invite your audience to debate in the comments.'),
      ('Behind the scenes of $topic', 'Show the messy, unpolished side of $topic. Authentic content builds trust.'),
      ('Q&A: your $topic questions', 'Collect questions via a story sticker, then answer the top 3 in a single video.'),
    ]);
    return templates.take(4).map((t) {
      return ContentIdea(
        id: _id(),
        type: IdeaType.postIdea,
        title: t.$1,
        body: '${_toneOpener(tone)} ${t.$2} ${_toneEmoji(tone)}',
        tags: [_pick(['Reel', 'Carousel', 'Story', 'Video']), _pick(['High reach', 'Save-worthy', 'Comment bait', 'Shareable'])],
        createdAt: DateTime.now(),
      );
    }).toList();
  }

  List<ContentIdea> _captions(String topic, Tone tone) {
    final bodies = switch (tone) {
      Tone.funny => [
          'Me: I\'ll just spend 5 minutes on $topic.\nAlso me, 3 hours later: 🫠\n\nTag someone who does this too 👇',
          'If $topic was a person, we\'d be in a committed relationship by now 😂 Who else is obsessed?',
          'Nobody:\nAbsolutely nobody:\nMe at 2 AM: researching $topic 🤓\n\nTell me I\'m not alone.',
        ],
      Tone.professional => [
          '3 lessons I learned from $topic this month:\n\n1️⃣ Consistency beats intensity\n2️⃣ Measure what matters\n3️⃣ Iterate fast\n\nWhich resonates most with you?',
          'Most people overcomplicate $topic. Here\'s a simple framework that works — save this for later 📌',
          'The data is clear: small daily improvements in $topic compound. Here\'s how I track mine. 📊',
        ],
      Tone.inspiring => [
          'A year ago I knew nothing about $topic. Today I\'m sharing it with you. Your journey starts with one step ✨',
          'Progress, not perfection. Every day you show up for $topic is a win 🌱\n\nWhat\'s your small win today?',
          'You don\'t have to be great to start $topic — but you have to start to be great 🔥',
        ],
      Tone.casual => [
          'Just a little $topic moment to brighten your feed ☕ How\'s your week going?',
          'Okay real talk — $topic has been my whole personality lately 😅 Anyone else?',
          'Sharing my current $topic setup because you asked 🙌 Questions? Drop them below!',
        ],
    };
    return _shuffled(bodies).map((b) {
      return ContentIdea(
        id: _id(),
        type: IdeaType.caption,
        title: '${tone.label} caption',
        body: b,
        createdAt: DateTime.now(),
      );
    }).toList();
  }

  List<ContentIdea> _hashtags(String topic, String? niche) {
    final slug = topic.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final n = (niche ?? 'creator').toLowerCase();
    final sets = [
      ('Broad reach', ['#$slug', '#${n}life', '#instagood', '#explorepage', '#trending', '#viral', '#contentcreator', '#reels']),
      ('Niche & targeted', ['#${slug}tips', '#${slug}community', '#${n}inspo', '#${n}creator', '#learn$slug', '#${slug}daily', '#${n}goals']),
      ('Engagement boosters', ['#${slug}challenge', '#${slug}hacks', '#${n}motivation', '#tipsandtricks', '#savethis', '#didyouknow', '#${slug}2026']),
    ];
    return sets.map((s) {
      return ContentIdea(
        id: _id(),
        type: IdeaType.hashtags,
        title: s.$1,
        body: '${s.$2.length} hashtags',
        tags: _shuffled(s.$2),
        createdAt: DateTime.now(),
      );
    }).toList();
  }

  List<ContentIdea> _calendar(String topic, Tone tone) {
    const plan = [
      ('Motivation Monday', 'Image', '7:00 AM'),
      ('Tutorial Tuesday', 'Reel', '6:00 PM'),
      ('Behind the scenes', 'Story', '12:00 PM'),
      ('Throwback / transformation', 'Carousel', '7:00 PM'),
      ('Fun Friday trend', 'Reel', '6:30 PM'),
      ('Weekend Q&A', 'Video', '10:00 AM'),
      ('Community spotlight', 'Story', '8:00 PM'),
    ];
    return List.generate(7, (i) {
      final p = plan[i];
      return ContentIdea(
        id: _id(),
        type: IdeaType.calendar,
        title: '${p.$1}: $topic',
        body: '${_toneOpener(tone)} ${_pick([
              'share a quick tip about $topic',
              'show your process for $topic',
              'ask your audience about $topic',
              'post a relatable $topic moment',
            ])} ${_toneEmoji(tone)}',
        tags: [p.$2],
        weekday: i,
        suggestedTime: p.$3,
        createdAt: DateTime.now(),
      );
    });
  }
}

/// Placeholder REST endpoints for the future backend.
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://api.createiq.app/v1';

  static const String login = '$baseUrl/auth/login';
  static const String signUp = '$baseUrl/auth/signup';
  static const String googleSignIn = '$baseUrl/auth/google';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String connectAccount = '$baseUrl/accounts/connect';
  static const String posts = '$baseUrl/posts';
  static const String generateContent = '$baseUrl/ai/generate';
  static const String askAI = '$baseUrl/ai/chat';
  static const String insights = '$baseUrl/ai/insights';
}
