/// Which AI Studio generator produced an idea.
enum IdeaType {
  postIdea('Post Ideas'),
  caption('Captions'),
  hashtags('Hashtags'),
  calendar('Content Calendar');

  const IdeaType(this.label);
  final String label;

  static IdeaType fromName(String name) =>
      IdeaType.values.firstWhere((t) => t.name == name, orElse: () => IdeaType.postIdea);
}

/// Voice the AI should write in.
enum Tone {
  funny('Funny', '😄'),
  professional('Professional', '💼'),
  inspiring('Inspiring', '✨'),
  casual('Casual', '😎');

  const Tone(this.label, this.emoji);
  final String label;
  final String emoji;
}

/// A single AI-generated suggestion (idea, caption, hashtag set or calendar slot).
class ContentIdea {
  const ContentIdea({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.tags = const [],
    this.weekday,
    this.suggestedTime,
    required this.createdAt,
  });

  final String id;
  final IdeaType type;
  final String title;
  final String body;
  final List<String> tags;

  /// For calendar items: 0 = Monday … 6 = Sunday.
  final int? weekday;

  /// For calendar items, e.g. "6:00 PM".
  final String? suggestedTime;

  final DateTime createdAt;

  /// Plain text representation for copying to the clipboard.
  String get copyText => [
        if (type != IdeaType.hashtags) body,
        if (tags.isNotEmpty) tags.join(' '),
      ].join('\n\n');

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'body': body,
        'tags': tags,
        'weekday': weekday,
        'suggestedTime': suggestedTime,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ContentIdea.fromJson(Map<String, dynamic> json) => ContentIdea(
        id: json['id'] as String,
        type: IdeaType.fromName(json['type'] as String),
        title: json['title'] as String,
        body: json['body'] as String,
        tags: (json['tags'] as List<dynamic>? ?? []).cast<String>(),
        weekday: json['weekday'] as int?,
        suggestedTime: json['suggestedTime'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
