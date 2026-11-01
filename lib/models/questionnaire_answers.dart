import 'post.dart';

/// Answers from the guided setup questionnaire; used to personalise AI output.
class QuestionnaireAnswers {
  const QuestionnaireAnswers({
    this.niche,
    this.ageRange,
    this.location = '',
    this.goal,
    this.postsPerWeek = 3,
    this.contentTypes = const {},
    this.avgLikes = 0,
    this.avgComments = 0,
    this.completed = false,
  });

  final String? niche;
  final String? ageRange;
  final String location;
  final String? goal;
  final int postsPerWeek;
  final Set<PostType> contentTypes;
  final int avgLikes;
  final int avgComments;

  /// True once the user has finished every step.
  final bool completed;

  QuestionnaireAnswers copyWith({
    String? niche,
    String? ageRange,
    String? location,
    String? goal,
    int? postsPerWeek,
    Set<PostType>? contentTypes,
    int? avgLikes,
    int? avgComments,
    bool? completed,
  }) =>
      QuestionnaireAnswers(
        niche: niche ?? this.niche,
        ageRange: ageRange ?? this.ageRange,
        location: location ?? this.location,
        goal: goal ?? this.goal,
        postsPerWeek: postsPerWeek ?? this.postsPerWeek,
        contentTypes: contentTypes ?? this.contentTypes,
        avgLikes: avgLikes ?? this.avgLikes,
        avgComments: avgComments ?? this.avgComments,
        completed: completed ?? this.completed,
      );

  Map<String, dynamic> toJson() => {
        'niche': niche,
        'ageRange': ageRange,
        'location': location,
        'goal': goal,
        'postsPerWeek': postsPerWeek,
        'contentTypes': contentTypes.map((t) => t.name).toList(),
        'avgLikes': avgLikes,
        'avgComments': avgComments,
        'completed': completed,
      };

  factory QuestionnaireAnswers.fromJson(Map<String, dynamic> json) => QuestionnaireAnswers(
        niche: json['niche'] as String?,
        ageRange: json['ageRange'] as String?,
        location: json['location'] as String? ?? '',
        goal: json['goal'] as String?,
        postsPerWeek: json['postsPerWeek'] as int? ?? 3,
        contentTypes: (json['contentTypes'] as List<dynamic>? ?? [])
            .map((n) => PostType.fromName(n as String))
            .toSet(),
        avgLikes: json['avgLikes'] as int? ?? 0,
        avgComments: json['avgComments'] as int? ?? 0,
        completed: json['completed'] as bool? ?? false,
      );
}
