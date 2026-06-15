class WordLinkModel {
  const WordLinkModel({
    required this.targetLessonId,
    required this.label,
    required this.type,
    required this.reason,
  });

  final String targetLessonId;
  final String label;
  final String type;
  final String reason;

  factory WordLinkModel.fromJson(Map<String, dynamic> json) {
    return WordLinkModel(
      targetLessonId: json['targetLessonId'] as String,
      label: json['label'] as String,
      type: json['type'] as String,
      reason: json['reason'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetLessonId': targetLessonId,
      'label': label,
      'type': type,
      'reason': reason,
    };
  }
}
