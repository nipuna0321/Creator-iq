enum ContentPlanStatus {
  planned,
  inProduction,
  readyToPublish,
  published;

  String get label {
    switch (this) {
      case ContentPlanStatus.planned:
        return 'Planned';
      case ContentPlanStatus.inProduction:
        return 'In Production';
      case ContentPlanStatus.readyToPublish:
        return 'Ready to Post';
      case ContentPlanStatus.published:
        return 'Published';
    }
  }
}

class ContentPlan {
  final String id;
  final String topic;
  final String platform;
  final String contentType;
  final DateTime scheduledDate;
  final ContentPlanStatus status;
  final String rationale;
  final String? notes;
  final String? targetMetric;

  const ContentPlan({
    required this.id,
    required this.topic,
    required this.platform,
    required this.contentType,
    required this.scheduledDate,
    this.status = ContentPlanStatus.planned,
    required this.rationale,
    this.notes,
    this.targetMetric,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topic': topic,
      'platform': platform,
      'content_type': contentType,
      'scheduled_date': scheduledDate.toIso8601String(),
      'status': status.name,
      'rationale': rationale,
      'notes': notes,
      'target_metric': targetMetric,
    };
  }

  factory ContentPlan.fromMap(Map<String, dynamic> map) {
    ContentPlanStatus parseStatus(String? name) {
      if (name == null) return ContentPlanStatus.planned;
      try {
        return ContentPlanStatus.values.firstWhere((e) => e.name == name);
      } catch (_) {
        return ContentPlanStatus.planned;
      }
    }

    return ContentPlan(
      id: map['id']?.toString() ?? '',
      topic: map['topic']?.toString() ?? '',
      platform: map['platform']?.toString() ?? 'Instagram',
      contentType: map['content_type']?.toString() ?? 'Reel',
      scheduledDate: DateTime.tryParse(map['scheduled_date']?.toString() ?? '') ?? DateTime.now(),
      status: parseStatus(map['status']?.toString()),
      rationale: map['rationale']?.toString() ?? '',
      notes: map['notes']?.toString(),
      targetMetric: map['target_metric']?.toString(),
    );
  }

  ContentPlan copyWith({
    String? id,
    String? topic,
    String? platform,
    String? contentType,
    DateTime? scheduledDate,
    ContentPlanStatus? status,
    String? rationale,
    String? notes,
    String? targetMetric,
  }) {
    return ContentPlan(
      id: id ?? this.id,
      topic: topic ?? this.topic,
      platform: platform ?? this.platform,
      contentType: contentType ?? this.contentType,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      status: status ?? this.status,
      rationale: rationale ?? this.rationale,
      notes: notes ?? this.notes,
      targetMetric: targetMetric ?? this.targetMetric,
    );
  }
}

