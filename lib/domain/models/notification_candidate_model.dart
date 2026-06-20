class NotificationCandidateModel {
  const NotificationCandidateModel({
    required this.lessonId,
    required this.word,
    required this.meaningEs,
    required this.level,
    required this.priority,
    required this.reason,
  });

  final String lessonId;
  final String word;
  final String meaningEs;
  final String level;
  final int priority;
  final String reason;
}
