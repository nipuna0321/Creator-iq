/// Supported social networks.
enum SocialPlatform {
  instagram('Instagram'),
  tiktok('TikTok'),
  youtube('YouTube'),
  facebook('Facebook'),
  x('X');

  const SocialPlatform(this.label);
  final String label;

  static SocialPlatform fromName(String name) =>
      SocialPlatform.values.firstWhere((p) => p.name == name, orElse: () => SocialPlatform.instagram);
}

/// Kinds of content a creator can publish.
enum PostType {
  image('Image'),
  video('Video'),
  reel('Reel'),
  story('Story');

  const PostType(this.label);
  final String label;

  static PostType fromName(String name) =>
      PostType.values.firstWhere((t) => t.name == name, orElse: () => PostType.image);
}

/// A single published post and its performance metrics.
class Post {
  const Post({
    required this.id,
    required this.platform,
    required this.type,
    required this.date,
    required this.caption,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.views = 0,
    this.saves = 0,
    this.followersGained = 0,
    this.followersAtPost = 10000,
    this.imagePath,
    this.isManual = false,
  });

  final String id;
  final SocialPlatform platform;
  final PostType type;
  final DateTime date;
  final String caption;
  final int likes;
  final int comments;
  final int shares;
  final int views;
  final int saves;
  final int followersGained;

  /// Follower count of the account when this post went out (denominator for engagement rate).
  final int followersAtPost;

  /// Optional local image path picked by the user (manual entries only).
  final String? imagePath;

  /// True when the user entered this post by hand rather than via a connected account.
  final bool isManual;

  /// Sum of all interactions on the post.
  int get interactions => likes + comments + shares + saves;

  /// Engagement rate = (likes + comments + shares + saves) / followers × 100.
  double get engagementRate => followersAtPost == 0 ? 0 : interactions / followersAtPost * 100;

  Post copyWith({
    SocialPlatform? platform,
    PostType? type,
    DateTime? date,
    String? caption,
    int? likes,
    int? comments,
    int? shares,
    int? views,
    int? saves,
    int? followersGained,
    int? followersAtPost,
    String? imagePath,
    bool clearImage = false,
  }) {
    return Post(
      id: id,
      platform: platform ?? this.platform,
      type: type ?? this.type,
      date: date ?? this.date,
      caption: caption ?? this.caption,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      views: views ?? this.views,
      saves: saves ?? this.saves,
      followersGained: followersGained ?? this.followersGained,
      followersAtPost: followersAtPost ?? this.followersAtPost,
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      isManual: isManual,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'platform': platform.name,
        'type': type.name,
        'date': date.toIso8601String(),
        'caption': caption,
        'likes': likes,
        'comments': comments,
        'shares': shares,
        'views': views,
        'saves': saves,
        'followersGained': followersGained,
        'followersAtPost': followersAtPost,
        'imagePath': imagePath,
        'isManual': isManual,
      };

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json['id'] as String,
        platform: SocialPlatform.fromName(json['platform'] as String),
        type: PostType.fromName(json['type'] as String),
        date: DateTime.parse(json['date'] as String),
        caption: json['caption'] as String? ?? '',
        likes: json['likes'] as int? ?? 0,
        comments: json['comments'] as int? ?? 0,
        shares: json['shares'] as int? ?? 0,
        views: json['views'] as int? ?? 0,
        saves: json['saves'] as int? ?? 0,
        followersGained: json['followersGained'] as int? ?? 0,
        followersAtPost: json['followersAtPost'] as int? ?? 10000,
        imagePath: json['imagePath'] as String?,
        isManual: json['isManual'] as bool? ?? false,
      );
}
