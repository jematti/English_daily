class UserProgressModel {
  const UserProgressModel({
    this.learnedLessonIds = const [],
    this.practicedLessonIds = const [],
    this.totalPracticeSessions = 0,
    this.totalCorrectAnswers = 0,
    this.totalWrongAnswers = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastStudyDate,
    this.levelProgress = const {},
  });

  final List<String> learnedLessonIds;
  final List<String> practicedLessonIds;
  final int totalPracticeSessions;
  final int totalCorrectAnswers;
  final int totalWrongAnswers;
  final int currentStreak;
  final int bestStreak;
  final String? lastStudyDate;
  final Map<String, int> levelProgress;

  int get totalAnswers => totalCorrectAnswers + totalWrongAnswers;

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    final learnedIds = List<String>.from(
      json['learnedLessonIds'] as List<dynamic>? ??
          json['completedLessonIds'] as List<dynamic>? ??
          const [],
    );

    return UserProgressModel(
      learnedLessonIds: learnedIds,
      practicedLessonIds: List<String>.from(
        json['practicedLessonIds'] as List<dynamic>? ?? const [],
      ),
      totalPracticeSessions: json['totalPracticeSessions'] as int? ?? 0,
      totalCorrectAnswers: json['totalCorrectAnswers'] as int? ?? 0,
      totalWrongAnswers: json['totalWrongAnswers'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      lastStudyDate: json['lastStudyDate'] as String?,
      levelProgress: _parseLevelProgress(json['levelProgress']),
    );
  }

  UserProgressModel copyWith({
    List<String>? learnedLessonIds,
    List<String>? practicedLessonIds,
    int? totalPracticeSessions,
    int? totalCorrectAnswers,
    int? totalWrongAnswers,
    int? currentStreak,
    int? bestStreak,
    String? lastStudyDate,
    Map<String, int>? levelProgress,
  }) {
    return UserProgressModel(
      learnedLessonIds: learnedLessonIds ?? this.learnedLessonIds,
      practicedLessonIds: practicedLessonIds ?? this.practicedLessonIds,
      totalPracticeSessions:
          totalPracticeSessions ?? this.totalPracticeSessions,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      totalWrongAnswers: totalWrongAnswers ?? this.totalWrongAnswers,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      levelProgress: levelProgress ?? this.levelProgress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'learnedLessonIds': learnedLessonIds,
      'practicedLessonIds': practicedLessonIds,
      'totalPracticeSessions': totalPracticeSessions,
      'totalCorrectAnswers': totalCorrectAnswers,
      'totalWrongAnswers': totalWrongAnswers,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'lastStudyDate': lastStudyDate,
      'levelProgress': levelProgress,
    };
  }

  static Map<String, int> _parseLevelProgress(Object? value) {
    if (value is! Map<String, dynamic>) {
      return const {};
    }

    return value.map((key, rawValue) {
      final parsedValue = rawValue is int
          ? rawValue
          : int.tryParse('$rawValue');
      return MapEntry(key, parsedValue ?? 0);
    });
  }
}
