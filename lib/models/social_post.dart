/// Model representing a single social media post and its performance metrics.
class SocialPost {
  final String id;
  final String platform; // Instagram, YouTube, TikTok, Facebook, etc.
  final String contentType; // Reel, Video, Carousel, Short, Static Image
  final String caption;
  final DateTime publishedAt;
  final int views;
  final int reach;
  final int likes;
  final int comments;
  final int shares;
  final double? watchTimeSeconds;

  const SocialPost({
    required this.id,
    required this.platform,
    required this.contentType,
    required this.caption,
    required this.publishedAt,
    required this.views,
    required this.reach,
    required this.likes,
    required this.comments,
    required this.shares,
    this.watchTimeSeconds,
  });

  /// Total social interactions (Likes + Comments + Shares)
  int get totalInteractions => likes + comments + shares;

  /// Engagement Rate computed as (Interactions / Reach) * 100.
  /// Returns null if reach is 0 or negative to prevent misleading calculations.
  double? get engagementRateByReach {
    if (reach <= 0) return null;
    return (totalInteractions / reach) * 100;
  }

  /// Engagement rate as formatted string (e.g., "7.8%")
  String get formattedEngagement {
    final rate = engagementRateByReach;
    if (rate == null) return 'N/A';
    return '${rate.toStringAsFixed(1)}%';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'platform': platform,
      'content_type': contentType,
      'caption': caption,
      'published_at': publishedAt.toIso8601String(),
      'views': views,
      'reach': reach,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'watch_time_seconds': watchTimeSeconds,
    };
  }

  factory SocialPost.fromMap(Map<String, dynamic> map) {
    return SocialPost(
      id: map['id']?.toString() ?? '',
      platform: map['platform']?.toString() ?? 'Other',
      contentType: map['content_type']?.toString() ?? 'Post',
      caption: map['caption']?.toString() ?? '',
      publishedAt: DateTime.tryParse(map['published_at']?.toString() ?? '') ?? DateTime.now(),
      views: int.tryParse(map['views']?.toString() ?? '0') ?? 0,
      reach: int.tryParse(map['reach']?.toString() ?? '0') ?? 0,
      likes: int.tryParse(map['likes']?.toString() ?? '0') ?? 0,
      comments: int.tryParse(map['comments']?.toString() ?? '0') ?? 0,
      shares: int.tryParse(map['shares']?.toString() ?? '0') ?? 0,
      watchTimeSeconds: map['watch_time_seconds'] != null
          ? double.tryParse(map['watch_time_seconds'].toString())
          : null,
    );
  }

  SocialPost copyWith({
    String? id,
    String? platform,
    String? contentType,
    String? caption,
    DateTime? publishedAt,
    int? views,
    int? reach,
    int? likes,
    int? comments,
    int? shares,
    double? watchTimeSeconds,
  }) {
    return SocialPost(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      contentType: contentType ?? this.contentType,
      caption: caption ?? this.caption,
      publishedAt: publishedAt ?? this.publishedAt,
      views: views ?? this.views,
      reach: reach ?? this.reach,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      watchTimeSeconds: watchTimeSeconds ?? this.watchTimeSeconds,
    );
  }
}

