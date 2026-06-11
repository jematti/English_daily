class UserProgressModel {
  const UserProgressModel({
    required this.completedLessonIds,
    required this.favoriteLessonIds,
    required this.currentStreak,
    required this.bestStreak,
    required this.lastStudyDate,
    required this.totalCompleted,
  });

  final List<String> completedLessonIds;
  final List<String> favoriteLessonIds;
  final int currentStreak;
  final int bestStreak;
  final String? lastStudyDate;
  final int totalCompleted;

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    return UserProgressModel(
      completedLessonIds: List<String>.from(
        json['completedLessonIds'] as List<dynamic>? ?? const [],
      ),
      favoriteLessonIds: List<String>.from(
        json['favoriteLessonIds'] as List<dynamic>? ?? const [],
      ),
      currentStreak: json['currentStreak'] as int,
      bestStreak: json['bestStreak'] as int,
      lastStudyDate: json['lastStudyDate'] as String?,
      totalCompleted: json['totalCompleted'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completedLessonIds': completedLessonIds,
      'favoriteLessonIds': favoriteLessonIds,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'lastStudyDate': lastStudyDate,
      'totalCompleted': totalCompleted,
    };
  }
}
