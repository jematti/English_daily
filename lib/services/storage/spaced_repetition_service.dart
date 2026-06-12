import 'package:english_drops_daily/domain/models/spaced_repetition_model.dart';

class SpacedRepetitionService {
  const SpacedRepetitionService();

  List<SpacedRepetitionModel> getInitialSchedule(List<String> lessonIds) {
    final tomorrow = _dateOnly(DateTime.now().add(const Duration(days: 1)));

    return lessonIds.map((lessonId) {
      return SpacedRepetitionModel(
        lessonId: lessonId,
        reviewLevel: 0,
        nextReviewDate: _formatDate(tomorrow),
        lastReviewedDate: null,
        correctCount: 0,
        wrongCount: 0,
      );
    }).toList();
  }

  SpacedRepetitionModel updateAfterAnswer({
    required SpacedRepetitionModel item,
    required bool wasCorrect,
  }) {
    final today = _dateOnly(DateTime.now());
    final nextLevel = wasCorrect ? item.reviewLevel + 1 : 0;
    final nextReviewDate = today.add(
      Duration(days: wasCorrect ? _intervalForLevel(nextLevel) : 1),
    );

    return SpacedRepetitionModel(
      lessonId: item.lessonId,
      reviewLevel: nextLevel,
      nextReviewDate: _formatDate(nextReviewDate),
      lastReviewedDate: _formatDate(today),
      correctCount: wasCorrect ? item.correctCount + 1 : item.correctCount,
      wrongCount: wasCorrect ? item.wrongCount : item.wrongCount + 1,
    );
  }

  List<SpacedRepetitionModel> getDueReviews(List<SpacedRepetitionModel> items) {
    final today = _dateOnly(DateTime.now());

    return items.where((item) {
      final reviewDate = _dateOnly(DateTime.parse(item.nextReviewDate));
      return !reviewDate.isAfter(today);
    }).toList();
  }

  int _intervalForLevel(int reviewLevel) {
    if (reviewLevel >= 5) {
      return 30;
    }

    return switch (reviewLevel) {
      0 => 1,
      1 => 2,
      2 => 4,
      3 => 7,
      4 => 14,
      _ => 30,
    };
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _formatDate(DateTime date) {
    return date.toIso8601String().split('T').first;
  }
}
