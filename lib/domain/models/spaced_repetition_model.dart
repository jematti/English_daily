class SpacedRepetitionModel {
  const SpacedRepetitionModel({
    required this.lessonId,
    required this.reviewLevel,
    required this.nextReviewDate,
    required this.lastReviewedDate,
    required this.correctCount,
    required this.wrongCount,
  });

  final String lessonId;
  final int reviewLevel;
  final String nextReviewDate;
  final String? lastReviewedDate;
  final int correctCount;
  final int wrongCount;

  factory SpacedRepetitionModel.fromJson(Map<String, dynamic> json) {
    return SpacedRepetitionModel(
      lessonId: json['lessonId'] as String,
      reviewLevel: json['reviewLevel'] as int,
      nextReviewDate: json['nextReviewDate'] as String,
      lastReviewedDate: json['lastReviewedDate'] as String?,
      correctCount: json['correctCount'] as int,
      wrongCount: json['wrongCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'reviewLevel': reviewLevel,
      'nextReviewDate': nextReviewDate,
      'lastReviewedDate': lastReviewedDate,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
    };
  }
}
